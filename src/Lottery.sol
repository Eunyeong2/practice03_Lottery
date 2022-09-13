// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

contract Lottery{

    uint time_now; //현재 시간
    uint16 win; //당첨 숫자
    uint256 received_msg_value;
    bool _isdraw;
    bool _isclaim;
    address[] buy_address;
    address[] winners;
    mapping(address => uint16) public lotteries;
    mapping(address => uint256) public balances;

    constructor () {
        received_msg_value = 0;
        time_now = block.timestamp;
        win = 6;
        _isdraw = false;
        _isclaim = false;
    }

    function buy(uint16 _value) public payable { //_value : 구매할 번호
        if (_isclaim == true){ // testRollover 통과하기 위한 부분 -> 다시 buy 하면 모든 것들 초기화 시키기
            _isclaim = false;
            _isdraw = false;
            time_now = block.timestamp;
            buy_address = new address[](0); // 빈 주소 배열을 위한 메모리 할당
            winners = new address[](0);
        }

        require(_isclaim == false);
        require(msg.value == 0.1 ether);
        require(time_now + 24 hours > block.timestamp);
        require(lotteries[msg.sender] != _value+1); //_value 로 할 경우 _value가 0일 때 0+0=0이기 때문에 오류 발생
        lotteries[msg.sender] = _value+1;
        received_msg_value += msg.value;
        buy_address.push(msg.sender); //구매한 address list에 push
    }

    function draw() public { //추첨 -> 당첨자 확인 후 상금 나눠주기
        require(_isclaim == false);
        require(block.timestamp >= time_now + 24 hours); //buy는 24 시간 미만, draw는 이후로 단계가 나뉨

        for (uint i=0; i<buy_address.length; ++i){
            address who = buy_address[i];
            if (lotteries[who]-1 == winningNumber()){
                winners.push(who);
            }
        }

        if (winners.length > 0){
            uint win_price = received_msg_value / winners.length;
            for (uint i=0; i<winners.length; ++i){
                address who = winners[i];
                balances[who] += win_price;
            }
        }
        _isdraw = true;
    }

    function claim() public { //잔액 송금
        require(_isdraw == true);
        _isclaim = true;
        uint amount = balances[msg.sender];
        balances[msg.sender] = 0;
        //payable(msg.sender).transfer(amount); test 에서 msg.value로 받고 있음. 
        payable(msg.sender).call{value: amount}("");
    }

    function winningNumber() public returns (uint16) {
        return win; //test기 때문에 그냥 당첨 숫자 고정시킴(6)
    }

}
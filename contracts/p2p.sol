pragma solidity ^ 0.4.19;


import "./doubleauction.sol";


contract P2P is DoubleAuction {

//获取ask队列最优价格
  function getask(uint ask_index) public view returns(uint,uint) {
    
    return (AskLedger[ask_index].price,AskLedger[ask_index].amount);
   
  }


  //获取bid队列最优价格  
  function getbid(uint bid_index) public view returns(uint,uint) {
    
    return (BidLedger[bid_index].price,BidLedger[bid_index].amount);
   
   }


//卖家限价订单
  function Sell_changeLimit(uint _price, uint _amount) public returns(bool) {
      Sell_deleteLimit(msg.sender);
      return submitAskSeller(_price, _amount);
   }
//买家限价订单
   function Buy_changeLimit(uint _price, uint _amount) public returns(bool) {
       Buy_deleteLimit(msg.sender);
       return submitBidBuyer(_price, _amount);
    }

//卖家撤单
  function Sell_deleteLimit(address _owner) public {
    for(uint i = 0; i < AskLedger.length; i++ ){
      if (AskLedger[i].owner == _owner){
        uint temp = i;
        break;
      }
    }
    deleteAsk(temp);
  }

//买家撤单
  function Buy_deleteLimit(address _owner) public {
    for(uint i = 0; i < BidLedger.length; i++ ){
      if (BidLedger[i].owner == _owner){
        uint temp = i;
        break;
      }
    }
    deleteAsk(temp);
  }



  function deleteAsk(uint index) private {
      uint len = AskLedger.length;
      if (index >= len) return;
      for (uint i = index; i < len-1; i++) {
        AskLedger[i] = AskLedger[i+1];
      }

      delete AskLedger[len-1];
      AskLedger.length--;
    }

  function deleteBuy(uint index) private {
      uint len = BidLedger.length;
      if (index >= len) return;
      for (uint i = index; i < len-1; i++) {
        BidLedger[i] = BidLedger[i+1];
      }

      delete BidLedger[len-1];
      BidLedger.length--;
    }




//市价成交
  function Sell_marketorder(uint _amount) public returns (bool) {
   uint index = sellamount(_amount, msg.sender);
    return MatchForSeller(index);

  }



//为卖家匹配
function MatchForSeller(uint ask_index) public returns (bool) {
 uint bid_index = BidLedger.length - 1;
  while(bid_index >= 0 && AskLedger[ask_index].amount != 0) {

 if (AskLedger[ask_index].amount <= BidLedger[bid_index].amount) {
  uint sellamount =  BidLedger[bid_index].price * AskLedger[ask_index].amount;
  require(balance[BidLedger[bid_index].owner] > sellamount);
  payToken(bid_index, ask_index, sellamount);
  changeAmount(bid_index, ask_index, AskLedger[ask_index].amount, 0);
  emit Sent(BidLedger[bid_index].owner,AskLedger[ask_index].owner, sellamount);
  return cleanAskLedger(ask_index);
 }

 if (AskLedger[ask_index].amount > BidLedger[bid_index].amount) {
  uint payamount2 = BidLedger[bid_index].price * BidLedger[bid_index].amount;
  require(balance[BidLedger[bid_index].owner] > payamount2);
  payToken(bid_index, ask_index, payamount2);
  changeAmount(bid_index, ask_index, BidLedger[bid_index].amount, 1);
  cleanBidLedger(bid_index);
  emit Sent(BidLedger[bid_index].owner,AskLedger[ask_index].owner, payamount2);
  bid_index--;
  }

  }

  return true;

}



//市价成交
   function Buy_marketorder(uint _amount) public returns (bool) {
   uint index = buyamount(_amount, msg.sender);
   return MatchForSeller(index);

   }


//为买家匹配
function MatchForBuyer(uint bid_index) public returns (bool) {
  uint ask_index = AskLedger.length - 1;
 while(ask_index >= 0 && BidLedger[bid_index].amount != 0) {

 if (BidLedger[bid_index].amount <= AskLedger[ask_index].amount) {
  uint payamount1 = AskLedger[ask_index].price * BidLedger[bid_index].amount;
  require(balance[BidLedger[bid_index].owner] > payamount1);
  payToken(bid_index, ask_index, payamount1);
  changeAmount(bid_index, ask_index, BidLedger[bid_index].amount, 1);
  emit Sent(BidLedger[bid_index].owner,AskLedger[ask_index].owner, payamount1);
  return cleanBidLedger(bid_index);
 }

 if (BidLedger[bid_index].amount > AskLedger[ask_index].amount) {
  uint payamount2 = AskLedger[ask_index].price * AskLedger[ask_index].amount;
  require(balance[BidLedger[bid_index].owner] > payamount2);
  payToken(bid_index, ask_index, payamount2);
  changeAmount(bid_index, ask_index, AskLedger[ask_index].amount, 0);
  cleanAskLedger(ask_index);
  emit Sent(BidLedger[bid_index].owner,AskLedger[ask_index].owner, payamount2);
  ask_index--;
  }

  }

  return true;

}


  function sellamount(uint _amount, address _owner) private returns (uint) {
   for(uint i = 0; i < AskLedger.length; i++ ){
    if (AskLedger[i].owner == _owner){
     uint temp = i;
      break;
    }
  }
  AskLedger[temp].amount = _amount;
  return temp;

   }

   function buyamount(uint _amount, address _owner) private returns (uint) {
  for(uint i = 0; i < BidLedger.length; i++ ){
    if (BidLedger[i].owner == _owner){
      uint temp = i;
      break;
    }
  }
  BidLedger[temp].amount = _amount;
  return temp;

   }
 




}

pragma solidity ^ 0.4.19;

import "./prepare.sol";




contract DoubleAuction is Perpare{

    struct Buyer {
        address owner;
        uint price;
        uint amount;
        
    }
    struct Seller {
        address owner;
        uint price;
        uint amount;
        
    }

    Buyer[] public BidLedger;
    Seller[] public AskLedger;
    uint clearingprice;




   event Sent(address from , address to, uint amount);
   

   
 //买家投标
   function submitBidBuyer(uint _price, uint _amount) public returns (bool) {
       Buyer memory b;
       b.price = _price;
       b.amount = _amount;
       b.owner = msg.sender;
       require (balance[msg.sender] > _price * _amount * 2);
       balance[msg.sender] -= _price * _amount;
       
    

       for(uint i = 0; i < BidLedger.length; i++) {
           if (BidLedger[i].price > _price) {
               Buyer[] memory tempLedger = new Buyer[](BidLedger.length - i);
               for(uint j = 0; j < tempLedger.length; j++) {
                   tempLedger[j] = BidLedger[j+i];
               }
               BidLedger[i] = b;
               BidLedger.length ++;
               for(uint k = 0; k < tempLedger.length; k++) {
                   BidLedger[k+i+1] = tempLedger[k];
               }
               return true;
           }
       }
       BidLedger.push(b);
       return true;
   }




//卖家投标
   function submitAskSeller(uint _price, uint _amount) public returns (bool) {
       Seller memory a;
       a.price = _price;
       a.amount = _amount;
       a.owner = msg.sender;
       require (balance[msg.sender] > _price * _amount * 2);
       balance[msg.sender] -= _price * _amount;
   

       for(uint i = 0; i < AskLedger.length; i++) {
           if(AskLedger[i].price < _price) {
               Seller[] memory tempLedger = new Seller[](AskLedger.length - i);
               for(uint j = 0; j < tempLedger.length; j++) {
                   tempLedger[j] = AskLedger[j+i];
               }
               AskLedger[i] = a;
               AskLedger.length += 1;
               for(uint k = 0; k < tempLedger.length; k++) {
                   AskLedger[k+i+1] = tempLedger[k];
               }
               return true;
           }
       }
       AskLedger.push(a);
       return true;
   }





//双向匹配
  function maTch() public onlyOwner {
    uint k = AskLedger.length - 1;
    for (int m = int(k); m >= 0; m--) {
        
             if (matchForSeller(uint(m))) {
                continue; 
             }
             else {
                 break;
             }
          }
         

     }
 



//为买家匹配
function matchForBuyer(uint bid_index) public returns (bool) {
  uint ask_index = AskLedger.length - 1;
 while(ask_index >= 0 && BidLedger[bid_index].amount != 0 && BidLedger[bid_index].price >= AskLedger[ask_index].price) {

 if (BidLedger[bid_index].amount <= AskLedger[ask_index].amount) {
  uint payamount1 = clearingPrice(bid_index, ask_index) * BidLedger[bid_index].amount;
  require(balance[BidLedger[bid_index].owner] > payamount1);
  payToken(bid_index, ask_index, payamount1);
  changeAmount(bid_index, ask_index, BidLedger[bid_index].amount, 1);
  cleanBidLedger(bid_index);
  emit Sent(BidLedger[bid_index].owner,AskLedger[ask_index].owner, payamount1);
  return cleanBidLedger(bid_index);
 }

 if (BidLedger[bid_index].amount > AskLedger[ask_index].amount) {
  uint payamount2 = clearingPrice(bid_index, ask_index) * AskLedger[ask_index].amount;
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


//为卖家匹配
function matchForSeller(uint ask_index) public returns (bool) {
 uint bid_index = BidLedger.length - 1;
  while(bid_index >= 0 && AskLedger[ask_index].amount != 0 && AskLedger[ask_index].price <= BidLedger[bid_index].price) {

 if (AskLedger[ask_index].amount <= BidLedger[bid_index].amount) {
  uint sellamount = clearingPrice(bid_index, ask_index) * AskLedger[ask_index].amount;
  require(balance[BidLedger[bid_index].owner] > sellamount);
  payToken(bid_index, ask_index, sellamount);
  changeAmount(bid_index, ask_index, AskLedger[ask_index].amount, 0);
  emit Sent(BidLedger[bid_index].owner,AskLedger[ask_index].owner, sellamount);
  return cleanAskLedger(ask_index);
 }

 if (AskLedger[ask_index].amount > BidLedger[bid_index].amount) {
  uint payamount2 = clearingPrice(bid_index, ask_index) * BidLedger[bid_index].amount;
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

//交易转账
function payToken(uint bid_index, uint ask_index, uint pay_amount) public {
  balance[AskLedger[ask_index].owner] +=  pay_amount;
  balance[BidLedger[bid_index].owner] -=  pay_amount;

}


//更新卖家出清队列
function cleanAskLedger(uint index) public returns (bool) {
    if (index > 0) {
    AskLedger.length = index;
    return true;
    }
    else {
    AskLedger.length = index; 
    return false;
    }
}

//更新买家出清队列
function cleanBidLedger(uint index) public returns (bool) {
    if(index > 0) {
    BidLedger.length = index;
    return true;
    }
    else {
    BidLedger.length = index;
    return false;  
    }
}

//更新出清队列余量和充电计划
function changeAmount (uint bid_index, uint ask_index, uint _amount, uint _flag) public {
  
  if (_flag == 0) {

    BidLedger[bid_index].amount -= _amount;
    AskLedger[ask_index].amount  = 0;
  }

  if(_flag == 1)  {

    BidLedger[bid_index].amount = 0;
    AskLedger[ask_index].amount -= _amount;
  }
  
}

   function getask(uint ask_index) public view returns(uint,uint){
       return (AskLedger[ask_index].price,AskLedger[ask_index].amount);
   }


   function getbid(uint bid_index) public view returns(uint,uint){
       return (BidLedger[bid_index].price,BidLedger[bid_index].amount);
   }


//成交价格
   function clearingPrice(uint bid_index, uint ask_index) public returns(uint) {

     clearingprice = (BidLedger[bid_index].price + AskLedger[ask_index].price) / 2;
     return clearingprice;

   }


}

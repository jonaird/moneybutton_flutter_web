# moneybutton_flutter_web

An experimental [MoneyButton](https://www.moneybutton.com) plugin for Flutter Web

## Usage

### MoneyButton(Map options, (optional) {width: double yourWidth})  


Displaying Money Buttons onscreen is very buggy because of an issue displaying iframes in Flutter web. You can use Invisible Money Button for the time being

Options is passed as is to the MoneyButton [javascript api](https://docs.moneybutton.com/docs/mb-javascript.html). Callbacks are not supported.

example:   
```
container(
  child:MoneyButton({"to": "jonathanaird@moneybutton.com", "amount": 1, "currency": "USD"}, width:300)
  )
``` 
 
 ### Invisible Money Button   
 This package includes a polyfill for the official [api](https://docs.moneybutton.com/docs/mb-invisible-money-button.html) with the one difference being that you use `IMB(options)` instead of `moneyButton.IMB(options)`; 
  
Example:
```var imb = IMB({'clientIdentifier':'your identifier','suggestedAmount':{'amount':'1','currency':'USD'},'onNewPermissionGranted':(String token){print(token);}});
```




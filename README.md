# moneybutton_flutter_web

An experimental [MoneyButton](https://www.moneybutton.com) plugin for Flutter Web

## Usage

### MoneyButton(Map options, (optional) {width: double yourWidth})

Options is passed as is to the MoneyButton [javascript api](https://docs.moneybutton.com/docs/mb-javascript.html). Callbacks are not supported.

example:   
```
container(
  child:MoneyButton({"to": "jonathanaird@moneybutton.com", "amount": 1, "currency": "USD"}, width:300)
  )
```



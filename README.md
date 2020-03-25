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

### Issues

For some reason the iframe reloads every time the cursor points over another native html element (such as text fields or iframes). If you can figure out why please submit an issue!



# stsr

App features:-


-Push notification for order status update.

-Wishlist.

-Payment gateway. COD and Online payment with UPI is provided

-user get coins for every product they buy. seller can set and update it for each product.

-Interactive material UI

-order and coins transaction history.

-Accounts secured with OTP.

-Cloud function is written in node.js you just need to deploy it.

-In short these apps provides every thing that a single seller application needs. you just need to follow the instructions to setup.

What you need to do is:

-Create a firebase project:

-create an android apps in it

-go to developers.google.com and get a free api key: Since googlemap is free for android apps

Add google-services.json to: android->app->

Add google maps api key to: android->app->src->main->AndroidManifest.xml

Add your upi id to recieve online payments in: lib->ui->widgets->user->payments.dart

PushNotification and deploy the firebase function written in node.js to firebase

Congratulations : Your single seller e-commerce app setup is ready. Expand your business online and enjoy. Apk is hardly 10mb

# stsrseller

App features:-

-Single seller e-commerce application with manpower provider feature.

-You are given two apps one is for seller and other one is for the customers.

-Push notification for order status update.

-seller can manually add everything. App is fully dynamic.

-Navigate to delivery address with google map.

-Set deliverable areas where you provide delivery.

-Payment gateway. COD and Online payment with UPI is provided

-user get coins for every product they buy. seller can set and update it for each product.

-Interactive material UI

-Dynamic promotional banner. seller can change them.

-order and coins transaction history.

-Accounts secured with OTP.

-Cloud function is written in node.js you just need to deploy it.

-In short these apps provides every thing that a single seller application needs. you just need to follow the instructions to setup.

What you need to do is:

-Create a firebase project (create only one firebase project for these two apps):

-create an android app:

-go to developers.google.com and get a free api key: Since googlemap is free for android apps

-Manually create a collection on firestore with name as seller and create a document with one field:array of string phone:add atleast one phone number for seller account
manually then furthur you can add from seller app from add admin option after loging in from a seller phone no. after OTP authentication.You can implement this in your own way also.

Add google-services.json to: android->app->

Add google maps api key to: android->app->src->main->AndroidManifest.xml

Place the document id of seller account you manually created in:lib->ui->widgets->start->register.dart on line 462 and 473

Congratulations : Your single seller app setup is ready. Expand your business online and enjoy. Apk is hardly 10mb

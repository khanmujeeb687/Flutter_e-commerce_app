const functions = require('firebase-functions');

const admin = require('firebase-admin');

admin.initializeApp();


exports.messageTrigger = functions.firestore.document('orders/{ordersId}').onUpdate( async (snapshot,context)=>{
    if(snapshot.empty){
        console.log("No document");
        return;
    }

    var tokens=[];

    const devicetokens = await admin
    .firestore()
    .collection("user")
    .doc(snapshot.after.data().userid)
    .get();


    var statusnow=snapshot.after.data().status;

    if(snapshot.after.data().status=="delivered" && snapshot.after.data().coins>0){
        statusnow=statusnow+" and "+snapshot.after.data().coins.toString()+" coins transfered to your waller successfully.";

       if(devicetokens.data().referredby!=""){
       var referredbydat= await admin
        .firestore()
        .collection("user")
        .where('referalid','==',devicetokens.data().referredby)
        .get();

        if(!referredbydat.empty){
            var payloadtoref =  {
                notification : {title:"stsr coins transfered", body:snapshot.after.data().coins.toString()+" coins successfully transfered to your wallet",sound:"default"},
                data : {click_action:"FLUTTER_NOTIFICATION_CLICK",message:"new popup notification"}
            };
            var temptok=[];    
            referredbydat.forEach((doc) => {
                temptok.push(doc.data().token);
              });
    
            try{
                const responsetemp = await admin.messaging().sendToDevice(temptok,payloadtoref);
            }catch(err){
        
            }
        }

       }
    }

    tokens.push(devicetokens.data().token);

    var payload = {
        notification : {title:"stsr order update", body:"Order status of "+snapshot.after.data().productname+": "+statusnow,sound:"default"},
        data : {click_action:"FLUTTER_NOTIFICATION_CLICK",message:"new popup notification"}
    };

    try{
        const response = await admin.messaging().sendToDevice(tokens,payload);
    }catch(err){

    }

}) ;



import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';

admin.initializeApp();

//const db = admin.firestore();
const fcm = admin.messaging();

export const sendWhenCreateEvent = functions.firestore
    .document('queue/{gameName}/active/{eventId}')
    .onCreate(async snapshot => {
        const event = snapshot.data() || [];

        const payload: admin.messaging.MessagingPayload = {
            notification: {
                title: `New ${event.game_name} Event!`,
                body: `Where? ${event.location} Come and check out more!`,
                icon: 'https://cmkt-image-prd.freetls.fastly.net/0.1.0/ps/2568933/910/607/m1/fpnw/wm0/1452%D0%BC%D1%81%D1%86%D1%8B-.jpg?1492634584&s=60fd9b8308802ec4418bc530469104c0',
                click_action: 'FLUTTER_NOTIFICATION_CLICK' // required only for onResume or onLaunch callbacks
            }
        };

        return fcm.sendToTopic('/topics/' + event.game_name, payload);
    });

export const sendWhenDeleteEvent = functions.firestore
    .document('queue/{gameName}/active/{eventId}')
    .onDelete(async snapshot => {
        const event = snapshot.data() || [];

        const payload: admin.messaging.MessagingPayload = {
            notification: {
                title: `${event.game_name} event canceled!`,
                body: ``,
                icon: 'https://cmkt-image-prd.freetls.fastly.net/0.1.0/ps/2568933/910/607/m1/fpnw/wm0/1452%D0%BC%D1%81%D1%86%D1%8B-.jpg?1492634584&s=60fd9b8308802ec4418bc530469104c0',
                click_action: 'FLUTTER_NOTIFICATION_CLICK' // required only for onResume or onLaunch callbacks
            }
        };

        return fcm.sendToTopic('/topics/' + event.game_name, payload);
    });

export const sendWhenCreateGame = functions.firestore
    .document('games/{gameId}')
    .onCreate(async snapshot => {
        const game = snapshot.data() || [];

        const payload: admin.messaging.MessagingPayload = {
            notification: {
                title: `New game added!`,
                body: `Come check out for new ${game.name} events`,
                icon: 'https://cmkt-image-prd.freetls.fastly.net/0.1.0/ps/2568933/910/607/m1/fpnw/wm0/1452%D0%BC%D1%81%D1%86%D1%8B-.jpg?1492634584&s=60fd9b8308802ec4418bc530469104c0',
                click_action: 'FLUTTER_NOTIFICATION_CLICK' // required only for onResume or onLaunch callbacks
            }
        };

        return fcm.sendToTopic('/topics/games', payload);
    });

export const sendWhenUpdateGame = functions.firestore
    .document('games/{gameId}')
    .onUpdate(async snapshot => {
        const game = snapshot.after.data() || [];

        const payload: admin.messaging.MessagingPayload = {
            notification: {
                title: `New updates!`,
                body: `Come check out for new ${game.name} updates`,
                icon: 'https://cmkt-image-prd.freetls.fastly.net/0.1.0/ps/2568933/910/607/m1/fpnw/wm0/1452%D0%BC%D1%81%D1%86%D1%8B-.jpg?1492634584&s=60fd9b8308802ec4418bc530469104c0',
                click_action: 'FLUTTER_NOTIFICATION_CLICK' // required only for onResume or onLaunch callbacks
            }
        };

        return fcm.sendToTopic('/topics/games', payload);
    });

export const sendWhenDeleteGame = functions.firestore
    .document('games/{gameId}')
    .onDelete(async snapshot => {
        const game = snapshot.data() || [];

        const payload: admin.messaging.MessagingPayload = {
            notification: {
                title: `Deleted game!`,
                body: `${game.name} events no longer exists.`,
                icon: 'https://cmkt-image-prd.freetls.fastly.net/0.1.0/ps/2568933/910/607/m1/fpnw/wm0/1452%D0%BC%D1%81%D1%86%D1%8B-.jpg?1492634584&s=60fd9b8308802ec4418bc530469104c0',
                click_action: 'FLUTTER_NOTIFICATION_CLICK' // required only for onResume or onLaunch callbacks
            }
        };

        return fcm.sendToTopic('/topics/games', payload);
    });

// export const sendToDevice = functions.firestore
//     .document('orders/{orderId}')
//     .onCreate(async snapshot => {
//
//
//         const order = snapshot.data() || [];
//
//         const querySnapshot = await db
//             .collection('users')
//             .doc(order.seller)
//             .collection('tokens')
//             .get();
//
//         const tokens = querySnapshot.docs.map(snap => snap.id);
//
//         const payload: admin.messaging.MessagingPayload = {
//             notification: {
//                 title: 'New Order!',
//                 body: `you sold a ${order.product} for ${order.total}`,
//                 icon: 'your-icon-url',
//                 click_action: 'FLUTTER_NOTIFICATION_CLICK'
//             }
//         };
//
//         return fcm.sendToDevice(tokens, payload);
//     });

// // Start writing Firebase Functions
// // https://firebase.google.com/docs/functions/typescript
//
// export const helloWorld = functions.https.onRequest((request, response) => {
//  response.send("Hello from Firebase!");
// });

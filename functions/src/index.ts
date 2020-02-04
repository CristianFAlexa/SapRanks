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
                click_action: 'FLUTTER_NOTIFICATION_CLICK' // required only for onResume or onLaunch callbacks
            },
            data: {
                tag: `${event.game_name}`,
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
                body: `Event no longer exists.`,
                click_action: 'FLUTTER_NOTIFICATION_CLICK' // required only for onResume or onLaunch callbacks
            },
            data: {
                tag: `${event.game_name}`,
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
                click_action: 'FLUTTER_NOTIFICATION_CLICK' // required only for onResume or onLaunch callbacks
            },
            data: {
                tag: `${game.name}`,
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
                click_action: 'FLUTTER_NOTIFICATION_CLICK' // required only for onResume or onLaunch callbacks
            },
            data: {
                tag: `${game.name}`,
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
                click_action: 'FLUTTER_NOTIFICATION_CLICK' // required only for onResume or onLaunch callbacks
            },
            data: {
                tag: `${game.name}`,
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

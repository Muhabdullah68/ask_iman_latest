const functions = require('firebase-functions');
const admin = require('firebase-admin');

admin.initializeApp();

const db = admin.firestore();

/**
 * When a new family reminder is created, send an FCM notification
 * to all group members via topic group_{groupId}.
 */
exports.onFamilyReminderCreate = functions.firestore
  .document('family_reminders/{reminderId}')
  .onCreate(async (snap, context) => {
    const reminder = snap.data();
    const groupId = reminder.groupId;
    const title = reminder.title || 'New Reminder';
    const creatorName = reminder.creatorName || 'Someone';
    const description = reminder.description || '';

    const groupDoc = await db.collection('family_groups').doc(groupId).get();
    if (!groupDoc.exists) return;

    const group = groupDoc.data();
    const memberIds = group.memberIds || [];
    const creatorId = reminder.creatorId;

    const payload = {
      notification: {
        title: `${creatorName} added: ${title}`,
        body: description || 'Tap to view the reminder',
      },
      data: {
        type: 'family_reminder',
        groupId: groupId,
        reminderId: context.params.reminderId,
        click_action: 'FLUTTER_NOTIFICATION_CLICK',
      },
      topic: `group_${groupId}`,
    };

    try {
      await admin.messaging().send(payload);
    } catch (e) {
      functions.logger.error('Failed to send reminder notification:', e);
    }
  });

/**
 * When a new family group message is sent, send an FCM notification
 * to all group members via topic group_{groupId}.
 */
exports.onFamilyGroupMessageCreate = functions.firestore
  .document('family_group_messages/{messageId}')
  .onCreate(async (snap, context) => {
    const message = snap.data();
    const groupId = message.groupId;
    const senderName = message.senderName || 'Someone';
    const text = message.text || '';

    const payload = {
      notification: {
        title: `${senderName} in your group`,
        body: text.length > 100 ? text.substring(0, 100) + '...' : text,
      },
      data: {
        type: 'family_message',
        groupId: groupId,
        messageId: context.params.messageId,
        click_action: 'FLUTTER_NOTIFICATION_CLICK',
      },
      topic: `group_${groupId}`,
    };

    try {
      await admin.messaging().send(payload);
    } catch (e) {
      functions.logger.error('Failed to send message notification:', e);
    }
  });

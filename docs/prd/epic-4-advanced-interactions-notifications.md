# Epic 4: Advanced Interactions & Notifications

**Goal:** Implement the final layer of advanced interactions. This includes the image-based transaction logging (Interaction Agent), the ability to share dashboard items to the chat, and the push notifications for alerts (Monitoring Agent).

---

## **Story 4.1: N8N Interaction Agent for Transactions**
**As a** User,
**I want** to upload a receipt image and a text note to log a transaction,
**so that** I can add expenses quickly without manual data entry.

**Acceptance Criteria:**
1.  A new n8n workflow named "Interaction Agent" is created.
2.  It is triggered when the Router Agent dispatches an `add_transaction` event containing text and an image URL (or base64 data).
3.  The workflow's logic for the MVP is to **simulate** OCR: it will extract the amount and category from the text note (e.g., "1M VND for food").
4.  It inserts a new record into the `transactions` table in PostgreSQL.
5.  It updates the user's budget in the `financial_data` table.
6.  It returns a confirmation message to the user (e.g., "Got it. I've logged a 1,000,000 VND transaction for Food.").

---

## **Story 4.2: N8N Monitoring Agent for Alerts**
**As a** User,
**I want** to be proactively notified about important financial events,
**so that** I can stay on top of my finances without having to constantly check the app.

**Acceptance Criteria:**
1.  A new n8n workflow named "Monitoring Agent" is created.
2.  It uses a **Schedule Trigger** to run periodically (e.g., every few hours).
3.  The workflow fetches all users and loops through them.
4.  For each user, it runs a simple check (e.g., "Has total spending in the 'Food' category exceeded the allocated budget?").
5.  If the condition is met, it inserts a record into the `alerts` table and uses a **notification node** (e.g., Pushover, FCM, or a simple webhook) to send an alert.
6.  The alert message is constructed in the user's preferred language.

---

## **Story 4.3: Rich Message Composer & Dashboard-to-Chat**
**As a** User,
**I want** to select an item from my dashboard and add it to my chat message,
**so that** I can easily ask questions about specific pieces of my financial data.

**Acceptance Criteria:**
1.  The chat interface's input/composer area is enhanced to handle a "rich message" containing multiple items (text, image, and now a "dashboard item").
2.  On the Dashboard screen, the user can long-press or tap an icon on a specific item (e.g., a recent transaction).
3.  This action adds a representation of that item (e.g., a small "chip" with the transaction details) to the chat composer.
4.  The user can then add text (e.g., "Was this a necessary expense?") and send the composite message to the Router Agent.
5.  The Router Agent is updated to handle this new type of payload containing a `dashboard_item` context.

---

## **Story 4.4: Flutter Push Notification Integration**
**As a** User,
**I want** to receive push notifications from FinGoal AI on my device,
**so that** I am immediately aware of important alerts from my advisor.

**Acceptance Criteria:**
1.  A push notification service (e.g., Firebase Cloud Messaging - FCM) is configured for the Flutter application.
2.  The app can receive and display a standard push notification sent from the Monitoring Agent's n8n workflow.
3.  Tapping the notification opens the FinGoal AI app.

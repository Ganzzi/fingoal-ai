# Epic 3: Chat Interface & Messaging

**Goal:** Build a comprehensive Flutter chat interface that enables seamless communication with the AI financial advisor system, supporting text and voice input with rich message rendering.

---

## **Story 3.1: Core Chat Interface**
**As a** User,
**I want** to have a chat interface where I can communicate with my financial advisor,
**so that** I can ask questions and receive advice in a natural, conversational way.

**Acceptance Criteria:**
1. A Flutter chat screen with message list and input composer is implemented.
2. Messages are displayed with clear distinction between user and AI agent messages.
4. Message timestamps and status indicators (sending, sent, delivered) are displayed.
5. Chat history is persisted locally and synced with the `messages` table in the database.
6. Auto-scroll to latest message and smooth scrolling animation.
7. Pull-to-refresh functionality to reload recent chat history.

---

## **Story 3.2: Message Input & Composition**
**As a** User,
**I want** to send text messages and voice recordings to my financial advisor,
**so that** I can communicate in my preferred method.

**Acceptance Criteria:**
1. Text input field with send button for typing messages.
2. Voice recording button with hold-to-record and tap-to-send functionality.
3. Visual feedback during voice recording (recording indicator, duration counter).
4. Voice message playback capability for sent voice messages.
5. Character counter for text messages with reasonable limits.
6. Message composition state persisted across app lifecycle (draft messages).
7. Emoji and basic formatting support in text messages.

---

## **Story 3.3: Chat API Integration**
**As a** Flutter App,
**I want** to send messages to the Router Agent and receive intelligent responses,
**so that** users can interact with the AI financial advisory system.

**Acceptance Criteria:**
1. HTTP service class for chat API communication with the Router Agent endpoint.
2. Proper authentication header inclusion (JWT token) in all requests.
3. Request payload includes: user_id, message content, language preference.
4. Response handling for different message types (text, forms, analysis results).
5. Error handling for network issues, authentication failures, and API errors.
6. Message retry mechanism for failed sends.
7. Typing indicators and message status updates.

---

## **Story 3.4: Voice Message Processing**
**As a** User,
**I want** my voice messages to be converted to text and processed by the AI,
**so that** I can communicate naturally without typing.

**Acceptance Criteria:**
1. Integration with device speech-to-text capabilities.
2. Support for both English and Vietnamese voice recognition.
3. Voice message converted to text before sending to Router Agent.
4. Option to review and edit transcribed text before sending.
5. Fallback handling when speech recognition fails or is unavailable.
6. Visual indicator showing transcription in progress.
7. Audio quality validation before processing.

---

## **Story 3.5: Rich Message Display**
**As a** User,
**I want** to receive well-formatted responses from my financial advisor,
**so that** information is easy to read and understand.

**Acceptance Criteria:**
1. Support for rendering formatted text (bold, italic, bullet points, numbered lists).
2. Special rendering for financial data (currency formatting, percentages).
3. Clickable links and references in AI responses.
4. Message threading/context indicators for multi-part conversations.
5. Code syntax highlighting for any technical explanations.
6. Proper text wrapping and responsive design for different screen sizes.
7. Support for rendering embedded data (mini charts, progress bars).

---

## **Story 3.6: Conversation Context Management**
**As a** System,
**I want** to maintain conversation context between the Flutter app and AI agents,
**so that** users receive coherent and contextual responses.

**Acceptance Criteria:**
1. Conversation session management with unique session IDs.
2. Context payload sent with each message including:
   - Recent message history (last 5-10 messages)
   - Current conversation topic/intent
   - User's financial context summary
3. Context persistence across app restarts and sessions.
4. Context reset functionality for starting new conversation topics.
5. Context size optimization to stay within API limits.
6. Conversation topic detection and automatic context switching.

---

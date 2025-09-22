# Epic 5: Financial Dashboard

**Goal:** Create a comprehensive dashboard system that displays all user financial data through a dedicated API and rich Flutter UI, providing visual insights into transactions, budgets, debts, investments, savings, goals, and insurance.

---

## **Story 5.1: Dashboard Data API**
**As a** Flutter App,
**I want** a comprehensive API that provides all user financial data in a structured format,
**so that** the dashboard can display a complete financial overview.

**Acceptance Criteria:**
1. An n8n workflow named "Dashboard API" created with GET endpoint `/webhook/dashboard`.
2. Fetches data from all financial tables and returns structured JSON:
   - `overview`: Net worth, cash flow, total debts, total assets
   - `accounts`: All money accounts with current balances
   - `transactions`: Recent transactions (last 30 days) with categories
   - `budgets`: Budget vs actual spending by category
   - `debts`: All debt accounts with balances, minimum payments, interest rates
   - `investments`: Investment accounts with current values and performance
   - `savings`: Savings goals with progress tracking
   - `goals`: Financial goals with timelines and progress
   - `insurance`: Insurance policies with coverage details
3. Data aggregation and calculations performed server-side.
4. Caching mechanism for frequently accessed data.
5. Error handling for missing or incomplete data.
6. **Reference:** Follow patterns in `docs/n8n_config_creation_instructions/4-data-processing-nodes.md`

---

## **Story 5.2: Dashboard Overview Screen**
**As a** User,
**I want** to see a comprehensive overview of my financial situation at a glance,
**so that** I can quickly understand my current financial health.

**Acceptance Criteria:**
1. Dashboard home screen showing key financial metrics:
   - Net worth with trend indicator
   - Monthly cash flow (income vs expenses)
   - Available cash across all accounts
   - Total debt with payoff timeline
   - Savings rate and emergency fund status
2. Visual indicators (colors, icons) for financial health status.
3. Quick action buttons for common tasks (add transaction, view budgets, etc.).
4. Pull-to-refresh functionality with loading states.
5. Responsive design adapting to different screen sizes.
6. Empty states for users with no financial data.

---

## **Story 5.3: Transactions & Spending Analysis**
**As a** User,
**I want** to view and analyze my spending patterns and transaction history,
**so that** I can understand where my money goes and identify areas for improvement.

**Acceptance Criteria:**
1. Transaction list with search and filtering capabilities:
   - Filter by date range, category, amount range, account
   - Search by description or merchant name
   - Sort by date, amount, or category
2. Spending analysis visualizations:
   - Monthly spending trends (line chart)
   - Category breakdown (pie chart or bar chart)
   - Comparison to budget allocations
3. Transaction details view with edit/delete capabilities.
4. Bulk transaction categorization and editing.
5. Export functionality for transaction data.
6. Spending insights and anomaly detection.

---

## **Story 5.4: Budget Management Interface**
**As a** User,
**I want** to view and manage my budgets with visual progress indicators,
**so that** I can stay on track with my spending goals.

**Acceptance Criteria:**
1. Budget overview showing all categories with:
   - Budgeted amount vs actual spending
   - Progress bars with color coding (green/yellow/red)
   - Remaining budget for each category
   - Days left in budget period
2. Budget creation and editing interface:
   - Set budget amounts for existing categories
   - Create new budget categories
   - Set budget periods (weekly, monthly, quarterly)
3. Budget alerts and notifications for overspending.
4. Historical budget performance tracking.
5. Budget recommendations based on spending patterns.

---

## **Story 5.5: Debt & Investment Tracking**
**As a** User,
**I want** to monitor my debts and investments with detailed progress tracking,
**so that** I can make informed decisions about debt payoff and investment strategies.

**Acceptance Criteria:**
1. Debt management section displaying:
   - All debt accounts with current balances
   - Interest rates and minimum payments
   - Debt payoff timelines and total interest costs
   - Debt avalanche vs snowball strategy comparisons
2. Investment tracking section showing:
   - Investment account balances and asset allocation
   - Performance metrics (gains/losses, ROI)
   - Portfolio diversity analysis
   - Investment goal progress
3. Interactive debt payoff calculator.
4. Investment performance charts and trends.
5. Recommendations for debt optimization and investment rebalancing.

---

## **Story 5.6: Goals & Savings Visualization**
**As a** User,
**I want** to visualize my progress towards financial goals and savings targets,
**so that** I stay motivated and on track to achieve my objectives.

**Acceptance Criteria:**
1. Goals dashboard showing:
   - All financial goals with progress bars
   - Target amounts, saved amounts, and timelines
   - Projected completion dates based on current savings rate
   - Goal priority and importance indicators
2. Savings tracking with:
   - Emergency fund status and target
   - Short-term and long-term savings goals
   - Automatic savings progress
   - Savings rate trends over time
3. Goal creation and editing interface.
4. Milestone celebrations and achievement badges.
5. Goal adjustment recommendations based on financial changes.
6. Visual timelines for multi-year goals.

---

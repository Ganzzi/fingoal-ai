curl -X POST http://localhost:5678/webhook/auth -H "Content-Type: application/json" -d '{"action": "register", "email": "testuser123@example.com", "password": "TestPassword123", "name": "Test User"}' -v

curl -X POST http://localhost:5678/webhook/auth -H "Content-Type: application/json" -d '{"action": "login", "email": "testuser123@example.com", "password": "TestPassword123", "name": "Test User"}' -v

curl -X POST http://localhost:5678/webhook/chat -H "Content-Type: application/json" -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHBpcmVzSW4iOiIyNGgiLCJ1c2VySWQiOiJiMTQ0YjY3MC02NTY5LTRiNjMtOTNlYS1mMWJkOGExODA0MWIiLCJlbWFpbCI6InRlc3R1c2VyMTIzQGV4YW1wbGUuY29tIiwiaWF0IjoxNzU4NTMxNTYyfQ.PKoZzwChAGwONSVcJJc67xta6BTYiBwvt-S35-bovv0" -d '{"message": "User just registered.", "type": "text", "language": "en"}' -v

curl -X GET http://localhost:5678/webhook/user/profile -H "Content-Type: application/json" -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHBpcmVzSW4iOiIyNGgiLCJ1c2VySWQiOiJiMTQ0YjY3MC02NTY5LTRiNjMtOTNlYS1mMWJkOGExODA0MWIiLCJlbWFpbCI6InRlc3R1c2VyMTIzQGV4YW1wbGUuY29tIiwiaWF0IjoxNzU4NTMxNTYyfQ.PKoZzwChAGwONSVcJJc67xta6BTYiBwvt-S35-bovv0"

curl -X GET http://localhost:5678/webhook/dashboard -H "Content-Type: application/json" -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHBpcmVzSW4iOiIyNGgiLCJ1c2VySWQiOiJiMTQ0YjY3MC02NTY5LTRiNjMtOTNlYS1mMWJkOGExODA0MWIiLCJlbWFpbCI6InRlc3R1c2VyMTIzQGV4YW1wbGUuY29tIiwiaWF0IjoxNzU4NTMxNTYyfQ.PKoZzwChAGwONSVcJJc67xta6BTYiBwvt-S35-bovv0"
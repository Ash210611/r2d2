aws appstream create-streaming-url --stack-name R2D2_User_nonProd --fleet-name r2d2_user_nonprod_fleet --user-id test_user --application-id TestApplication | jq


--headless  --remote-debugging-port=9222 https://appstream2.us-east-1.aws.amazon.com/authenticate?parameters=eyJ0eXBlIjoiRU5EX1VTRVIiLCJleHBpcmVzIjoiMTYwMDA5ODgxMiIsImF3c0FjY291bnRJZCI6Ijc3NjE3MTU5NTk1MSIsInVzZXJJZCI6InRlc3RfdXNlcjIiLCJjYXRhbG9nU291cmNlIjoic3RhY2svUjJEMl9Vc2VyX25vblByb2QiLCJmbGVldFJlZiI6ImZsZWV0L3IyZDJfdXNlcl9ub25wcm9kX2ZsZWV0IiwiYXBwbGljYXRpb25JZCI6IlRlc3RBcHBsaWNhdGlvbiIsInVzZXJDb250ZXh0IjoiIiwibWF4VXNlckR1cmF0aW9uSW5TZWNzIjoiNDMyMDAifQ%3D%3D

./firefox --headless 


./firefox $(aws appstream create-streaming-url --stack-name R2D2_User_nonProd --fleet-name r2d2_user_nonprod_fleet --user-id test_user1 --application-id TestApplication | jq -r ".StreamingURL")

google-chrome-stable --headless --disable-gpu --remote-debugging-port=9222 https://www.chromestatus.com
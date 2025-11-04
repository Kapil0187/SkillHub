#!/bin/bash
cd backend && rails s &          # Start Rails server from backend folder
cd ./frontend && npm run dev    # Start React dev server from frontend folder
wait

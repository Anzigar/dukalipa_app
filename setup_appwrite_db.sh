#!/bin/bash

# Appwrite Database Setup Script
# This script creates the database and collection structure for the Dukalipa Shop Management App

echo "🚀 Setting up Appwrite Database for Dukalipa App..."
echo "================================================"

# Configuration
DATABASE_ID="shop_management_db"
DATABASE_NAME="Shop Management DB"
COLLECTION_ID="users"
COLLECTION_NAME="Users"

# Check if appwrite CLI is installed
if ! command -v appwrite &> /dev/null; then
    echo "❌ Appwrite CLI is not installed!"
    echo "📥 Install it with: npm install -g appwrite-cli"
    echo "🔗 Or visit: https://appwrite.io/docs/command-line"
    exit 1
fi

echo "✅ Appwrite CLI found!"

# Create database
echo ""
echo "📊 Creating database: $DATABASE_NAME"
appwrite databases create \
    --database-id "$DATABASE_ID" \
    --name "$DATABASE_NAME"

if [ $? -eq 0 ]; then
    echo "✅ Database created successfully!"
else
    echo "⚠️  Database might already exist, continuing..."
fi

# Create users collection
echo ""
echo "👥 Creating users collection..."
appwrite databases create-collection \
    --database-id "$DATABASE_ID" \
    --collection-id "$COLLECTION_ID" \
    --name "$COLLECTION_NAME" \
    --permissions 'create("users")' 'read("users")' 'update("users")' 'delete("users")'

if [ $? -eq 0 ]; then
    echo "✅ Users collection created successfully!"
else
    echo "⚠️  Collection might already exist, continuing..."
fi

echo ""
echo "📝 Adding attributes to users collection..."

# Required String Attributes
echo "  ➕ Adding user_id attribute..."
appwrite databases create-string-attribute \
    --database-id "$DATABASE_ID" \
    --collection-id "$COLLECTION_ID" \
    --key "user_id" \
    --size 255 \
    --required true

echo "  ➕ Adding name attribute..."
appwrite databases create-string-attribute \
    --database-id "$DATABASE_ID" \
    --collection-id "$COLLECTION_ID" \
    --key "name" \
    --size 255 \
    --required true

echo "  ➕ Adding email attribute..."
appwrite databases create-string-attribute \
    --database-id "$DATABASE_ID" \
    --collection-id "$COLLECTION_ID" \
    --key "email" \
    --size 255 \
    --required true

echo "  ➕ Adding shop_name attribute..."
appwrite databases create-string-attribute \
    --database-id "$DATABASE_ID" \
    --collection-id "$COLLECTION_ID" \
    --key "shop_name" \
    --size 255 \
    --required true

# Optional String Attributes
echo "  ➕ Adding phone attribute..."
appwrite databases create-string-attribute \
    --database-id "$DATABASE_ID" \
    --collection-id "$COLLECTION_ID" \
    --key "phone" \
    --size 50 \
    --required false \
    --default ""

echo "  ➕ Adding shop_address attribute..."
appwrite databases create-string-attribute \
    --database-id "$DATABASE_ID" \
    --collection-id "$COLLECTION_ID" \
    --key "shop_address" \
    --size 500 \
    --required false \
    --default ""

echo "  ➕ Adding shop_phone attribute..."
appwrite databases create-string-attribute \
    --database-id "$DATABASE_ID" \
    --collection-id "$COLLECTION_ID" \
    --key "shop_phone" \
    --size 50 \
    --required false \
    --default ""

# DateTime Attributes
echo "  ➕ Adding created_at attribute..."
appwrite databases create-datetime-attribute \
    --database-id "$DATABASE_ID" \
    --collection-id "$COLLECTION_ID" \
    --key "created_at" \
    --required true

echo "  ➕ Adding updated_at attribute..."
appwrite databases create-datetime-attribute \
    --database-id "$DATABASE_ID" \
    --collection-id "$COLLECTION_ID" \
    --key "updated_at" \
    --required true

echo ""
echo "🎉 Database setup completed successfully!"
echo "================================================"
echo ""
echo "📋 Summary:"
echo "  Database ID: $DATABASE_ID"
echo "  Collection ID: $COLLECTION_ID"
echo "  Attributes: 9 total (4 required, 5 optional)"
echo ""
echo "🔧 Next steps:"
echo "  1. Update your environment.dart file with correct project details"
echo "  2. Test the authentication flow in your app"
echo "  3. Verify data is being saved to Appwrite console"
echo ""
echo "✨ Happy coding!"
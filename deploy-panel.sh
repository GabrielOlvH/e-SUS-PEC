#!/bin/bash

echo "========================================="
echo "   e-SUS PEC APS Panel Setup Script"
echo "========================================="

# Function to generate random password
generate_password() {
    openssl rand -base64 $1 2>/dev/null || LC_ALL=C tr -dc 'A-Za-z0-9' </dev/urandom | head -c $1
}

# Check if .env.panel exists
if [ ! -f .env.panel ]; then
    echo "❌ .env.panel file not found!"
    echo "Creating from template..."
    cp .env.panel .env.panel.local
    
    # Generate credentials
    ADMIN_PASS=$(generate_password 12)
    SECRET_TOKEN=$(generate_password 22)
    SALT_PART=$(generate_password 22 | tr -d /=+)
    PASSWORD_SALT='$2a$12$'$SALT_PART
    
    echo ""
    echo "📝 Generated Credentials:"
    echo "========================="
    echo "PANEL_ADMIN_PASSWORD=$ADMIN_PASS"
    echo "SECRET_TOKEN=$SECRET_TOKEN"
    echo "PASSWORD_SALT='$PASSWORD_SALT'"
    echo ""
    echo "⚠️  Save these credentials! Add them to .env.panel.local"
    echo ""
fi

# Check if database is running
if docker ps | grep -q "db"; then
    echo "✅ Database container is running"
    
    # Create read-only user
    echo "Creating read-only database user..."
    READ_PASS=$(generate_password 16)
    
    docker exec -i db psql -U postgres -d esus <<EOF
-- Create read-only user if not exists
DO \$\$
BEGIN
    IF NOT EXISTS (SELECT FROM pg_user WHERE usename = 'esus_leitura') THEN
        CREATE USER esus_leitura WITH PASSWORD '$READ_PASS';
    END IF;
END
\$\$;

-- Grant permissions
GRANT CONNECT ON DATABASE esus TO esus_leitura;
GRANT USAGE ON SCHEMA public TO esus_leitura;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO esus_leitura;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT SELECT ON TABLES TO esus_leitura;
EOF
    
    echo "✅ Read-only user created/updated"
    echo "📝 Database password for esus_leitura: $READ_PASS"
    echo "   Add this to .env.panel as PANEL_DB_PASSWORD"
else
    echo "⚠️  Database container not running. Start PEC first:"
    echo "   docker-compose -f docker-compose.coolify.yml up -d"
    exit 1
fi

echo ""
echo "========================================="
echo "Next steps:"
echo "1. Edit .env.panel with your configuration:"
echo "   - CIDADE_IBGE (your city code)"
echo "   - ESTADO (state abbreviation)"
echo "   - POPULATION (city population)"
echo "   - Add the generated passwords"
echo ""
echo "2. Start the panel:"
echo "   docker-compose -f docker-compose.panel.yml --env-file .env.panel up -d"
echo ""
echo "3. Access the panel at:"
echo "   http://localhost:5001"
echo "========================================="
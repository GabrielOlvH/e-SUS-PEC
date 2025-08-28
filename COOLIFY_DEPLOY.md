# 🚀 e-SUS PEC - Coolify Deployment Guide

This guide enables single-click deployment of e-SUS PEC on Coolify platform.

## 📋 Prerequisites

- Coolify instance installed and running
- GitHub/GitLab account with this repository forked/cloned
- Basic knowledge of Coolify dashboard

## 🎯 Quick Deploy (One-Click Setup)

### Step 1: Add New Resource in Coolify

1. Navigate to your Coolify dashboard
2. Click **"+ Add"** → **"New Resource"**
3. Select **"Docker Compose"** as deployment type

### Step 2: Configure Source

#### Option A: Git Repository (Recommended)
1. Select **"Public Repository"** or connect your GitHub/GitLab
2. Enter repository URL: `https://github.com/YOUR_USERNAME/e-SUS-PEC`
3. Branch: `main`
4. **Build Pack**: Select **"Docker Compose"**
5. **Compose Path**: `/docker-compose.coolify.yml`

#### Option B: Direct Compose File
1. Select **"Docker Compose (Empty)"**
2. Copy contents of `docker-compose.coolify.yml` to the editor

### Step 3: Environment Variables

1. Go to **"Environment Variables"** tab
2. Add the following variables:

```env
POSTGRES_DB=esus
POSTGRES_USER=postgres
TRAINING=false
TZ=America/Sao_Paulo
```

3. **Important**: Leave `POSTGRES_PASS` empty - Coolify will auto-generate secure password using `SERVICE_PASSWORD_POSTGRES`

### Step 4: Network & Domain Configuration

1. **Domain Settings**:
   - Coolify will auto-assign domain via `SERVICE_FQDN_PEC`
   - Or set custom domain in **"Domains"** tab

2. **Port Mapping**:
   - Application runs on port 8080 internally
   - Coolify handles external port mapping automatically

### Step 5: Deploy

1. Click **"Deploy"** button
2. Monitor deployment logs
3. Wait ~5-10 minutes for initial setup (downloads latest e-SUS PEC automatically)

## 🔧 Advanced Configuration

### Using External Database

To use an external PostgreSQL database:

1. Modify environment variables:
```env
POSTGRES_HOST=your-external-db-host
POSTGRES_PORT=5432
POSTGRES_DB=esus
POSTGRES_USER=your-db-user
POSTGRES_PASS=your-db-password
```

2. Remove the `db` service from docker-compose if using external database

### Production vs Training Mode

- **Production Mode**: Set `TRAINING=false`
- **Training/Demo Mode**: Set `TRAINING=true`
  - Default credentials: 
    - User: 969.744.190-15
    - Password: senha123

### Custom SSL Certificates

Coolify handles SSL automatically. For custom certificates:
1. Go to **"SSL/TLS"** tab in your application
2. Upload your certificates or use Let's Encrypt

## 📊 Resource Requirements

### Minimum Requirements:
- **CPU**: 2 cores
- **RAM**: 4GB
- **Storage**: 20GB

### Recommended for Production:
- **CPU**: 4 cores
- **RAM**: 8GB
- **Storage**: 50GB+

## 🔍 Health Checks

The deployment includes automatic health checks:
- PEC service: Checks port 8080 availability
- PostgreSQL: Verifies database connectivity

## 🛠️ Troubleshooting

### Container Not Starting

1. Check logs in Coolify dashboard
2. Verify environment variables are set correctly
3. Ensure sufficient resources

### Database Connection Issues

1. Check `POSTGRES_*` environment variables
2. Verify database service is running
3. Check network connectivity between services

### Application Access Issues

1. Wait for health checks to pass (may take 5 minutes on first deploy)
2. Check domain configuration in Coolify
3. Verify firewall rules allow traffic

## 🔄 Updates

### Automatic Updates
The AWS Dockerfile automatically downloads the latest e-SUS PEC version on build.

### Manual Update
1. Go to your application in Coolify
2. Click **"Redeploy"**
3. This will fetch and install the latest version

## 📝 Backup & Restore

### Creating Backups

SSH into your Coolify server and run:

```bash
docker exec -it pec bash -c 'pg_dump --host localhost --port 5432 -U "postgres" --format custom --blobs --encoding UTF8 --no-privileges --no-tablespaces --no-unlogged-table-data --file "/backups/$(date +"%Y_%m_%d__%H_%M_%S").backup" "esus"'
```

### Restore from Backup

```bash
docker exec -it pec bash -c 'pg_restore -U "postgres" -d "esus" -1 "/backups/your_backup_file.backup"'
```

## 🚨 Security Considerations

1. **Change default passwords** immediately after deployment
2. **Enable firewall** rules to restrict database access
3. **Regular backups** are essential for production
4. **Monitor logs** for suspicious activity
5. **Keep system updated** via regular redeployments

## 📞 Support

- GitHub Issues: [e-SUS-PEC Repository](https://github.com/filiperochalopes/e-SUS-PEC/issues)
- Official e-SUS Support: [ESUS APS Support](https://esusaps.freshdesk.com/support/login)
- WhatsApp Support: [Contact](https://wa.me/5571986056232)

## ✅ Post-Deployment Checklist

- [ ] Application accessible via assigned domain
- [ ] Login successful with credentials
- [ ] Database connection verified
- [ ] Backup strategy configured
- [ ] Monitoring/alerts set up
- [ ] SSL certificate active
- [ ] Resource usage within limits

## 🎉 Success!

Your e-SUS PEC instance should now be running on Coolify. Access it via the domain configured in Coolify's dashboard.

---

**Note**: This deployment uses the AWS optimized version that automatically downloads the latest e-SUS PEC release from the official source.
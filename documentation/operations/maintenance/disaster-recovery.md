# Disaster recovery

## Overview
For complete database loss or partial data loss scenarios, follow the procedures outlined in the Teacher Services Cloud project documentation:
- [Disaster recovery instructions](https://github.com/DFE-Digital/teacher-services-cloud/blob/main/documentation/disaster-recovery.md)
- [Disaster recovery testing instructions](https://github.com/DFE-Digital/teacher-services-cloud/blob/main/documentation/disaster-recovery-testing.md)

## Quick Action Links

### Pipeline Control
**Block/Unblock Deployments:**
- [Branch protection settings](https://github.com/DFE-Digital/teaching-vacancies/settings/branches)
- Set approval count to `6` (block) or `1` (unblock)
- Requires admin privileges

### Maintenance Mode
**Enable/Disable Maintenance:**
- [Maintenance mode workflow](https://github.com/DFE-Digital/teaching-vacancies/actions/workflows/maintenance.yml)

### Database Operations

**Restore from Backup:**
- [Database restore workflow](https://github.com/DFE-Digital/teaching-vacancies/actions/workflows/restore-db.yml)
- Required parameters:
  - Environment name
  - Production flag (true/false)
  - Backup filename

**Point-in-Time Recovery:**
- [Point-in-time restore workflow](https://github.com/DFE-Digital/teaching-vacancies/actions/workflows/restore-db-ptr.yml)

**Create Backup:**
- [Database backup workflow](https://github.com/DFE-Digital/teaching-vacancies/actions/workflows/backup_db.yml)
- Completion summary format:
```
BACKUP SUCCESSFUL!
APP: <environment>
AT: <backup-date>
DB SERVER: default for app
STORAGE ACCOUNT: <storage-account-id>
FILENAME: <backup-filename>
```

## Backup File Locations

### Azure Storage Accounts by Environment
| Environment | Storage Account | Direct Link |
|-------------|----------------|-------------|
| Production | `s189p01tvdbbkppdsa` | [Access](https://portal.azure.com/#@platform.education.gov.uk/resource/subscriptions/3c033a0c-7a1c-4653-93cb-0f2a9f57a391/resourceGroups/s189p01-tv-pd-rg/providers/Microsoft.Storage/storageAccounts/s189p01tvdbbkppdsa/storagebrowser) |
| Staging | `s189t01tvdbbkpstsa` | [Access](https://portal.azure.com/#@platform.education.gov.uk/resource/subscriptions/20da9d12-7ee1-42bb-b969-3fe9112964a7/resourceGroups/s189t01-tv-st-rg/providers/Microsoft.Storage/storageAccounts/s189t01tvdbbkpstsa/storagebrowser) |
| QA | `s189t01tvdbbkpqasa` | [Access](https://portal.azure.com/#@platform.education.gov.uk/resource/subscriptions/20da9d12-7ee1-42bb-b969-3fe9112964a7/resourceGroups/s189t01-tv-qa-rg/providers/Microsoft.Storage/storageAccounts/s189t01tvdbbkpqasa/storagebrowser) |

### Alternative Access Method
1. Navigate to [Azure Storage Accounts](https://portal.azure.com/#browse/Microsoft.Storage%2FStorageAccounts)
2. Search for the relevant storage account name (see table above)
3. Select the storage account
4. Click **Storage browser** in the left menu
5. Navigate to **Blob containers > database-backup**

**Note:** Production resource access requires PIM approval.

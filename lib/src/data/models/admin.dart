// SPDX-License-Identifier: AGPL-3.0-or-later

/// Tenants, their users and domains, global admins, account logs and the
/// server's live connections, as the administration screens read them.
library;

export 'package:tix_mobile/src/data/api/gen/models.gen.dart'
    show
        AccountLogEntry,
        AddDomainInput,
        AddTenantMemberInput,
        ArtifactLimits,
        ConnectionCounts,
        ConnectionList,
        ConnectionSurface,
        CreateTenantInput,
        CreateUserInput,
        CreatedAdmin,
        CreatedTenant,
        Domain,
        ForceReclaimInput,
        HealthBody,
        InitialCredential,
        LiveConnection,
        Role,
        SessionPolicy,
        Tenant,
        TenantAdminInput,
        TenantUser,
        UpdateTenantInput,
        UpdateUserInput,
        User;

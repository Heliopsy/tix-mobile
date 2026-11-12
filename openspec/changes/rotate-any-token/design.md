# Design

- **The web's rules.** Rotate is drawn only on an active row, Revoke on every row not yet revoked, as
  `internal/web/templates/tokens.html` draws them. A retiring token is already being replaced, so rotating it again
  is not offered; revoking it ends its grace early.
- **The server decides.** The app offers Rotate on every active row it lists. A caller with `tenant:admin` sees the
  whole tenant's tokens; whether they may rotate somebody else's is tix's answer, shown in the sheet as any refusal.
- **Graces.** The four windows and their labels are tix's `onboard.RotateGraces`. They are sent as Go durations
  (`0s`, `10m`, `1h`, `24h`), none past `core.MaxTokenRotateGrace`.
- **Retiring.** tix's `APIToken.Retiring`: `revoked_at` is set but still in the future and the token has not
  expired. Revoked means `revoked_at` has passed. The row says when it stops.
- **The app's own credential.** When the credential is an API token (whoami's `token_id`) on a remote token
  connection and the row is that token, the application layer calls `SessionController.rotateToken` with the chosen
  grace. That keeps the secure-storage check before the call, the swap afterwards, and the one-time display when
  the write fails. Every other row calls `TokenRepository.rotate`.
- **Showing the value.** The value sheet opens from the navigator's context rather than the row's, so a list that
  reloads after the rotation cannot drop the only copy of the value.

// Usage rules (SPEC section 3), as pure functions so they're easy to test.
//   Free: unlimited saving, reading, sorting, search + FREE_MAKES makes.
//   Pro ($19/month): monthly fair-use cap.
//   Failed or empty AI responses never count.
//   1 free regenerate per shot. Quick tweaks count as 0.

export interface UserRecord {
  is_pro: number;
  pro_expires_at: number | null;
  free_used: number;
}

export interface QuotaConfig {
  freeMakes: number;
  proMonthlyMakes: number;
}

export type MakeKind = 'make' | 'regenerate' | 'tweak';

export type Decision =
  | { allowed: true; charge: boolean; freeRegen: boolean }
  | { allowed: false; reason: 'free_used' | 'fair_use' | 'needs_draft' };

export function isProActive(u: UserRecord, now: number): boolean {
  return u.is_pro === 1 && (u.pro_expires_at == null || u.pro_expires_at > now);
}

export function decide(args: {
  user: UserRecord;
  kind: MakeKind;
  monthUsed: number;
  regenUsedForShot: boolean;
  hasPreviousDraft: boolean;
  config: QuotaConfig;
  now: number;
}): Decision {
  const { user, kind, monthUsed, regenUsedForShot, hasPreviousDraft, config, now } = args;

  if ((kind === 'tweak' || kind === 'regenerate') && !hasPreviousDraft) return { allowed: false, reason: 'needs_draft' };
  if (kind === 'tweak') return { allowed: true, charge: false, freeRegen: false };
  if (kind === 'regenerate' && !regenUsedForShot) return { allowed: true, charge: false, freeRegen: true };

  if (isProActive(user, now)) {
    return monthUsed < config.proMonthlyMakes ? { allowed: true, charge: true, freeRegen: false } : { allowed: false, reason: 'fair_use' };
  }
  return user.free_used < config.freeMakes ? { allowed: true, charge: true, freeRegen: false } : { allowed: false, reason: 'free_used' };
}

export function accountView(u: UserRecord, monthUsed: number, config: QuotaConfig, now: number) {
  const pro = isProActive(u, now);
  return {
    is_pro: pro,
    free_makes_left: Math.max(0, config.freeMakes - u.free_used),
    free_makes_total: config.freeMakes,
    monthly_makes_left: pro ? Math.max(0, config.proMonthlyMakes - monthUsed) : null,
  };
}

export function monthKey(now: number): string {
  return new Date(now).toISOString().slice(0, 7);
}

/** RevenueCat webhook -> Pro state. Refunds lock makes but keep data (SPEC edge case). */
export function proFromRevenueCat(event: { type: string; expiration_at_ms?: number | null; cancel_reason?: string | null }, now: number):
  | { is_pro: 0 | 1; pro_expires_at: number | null }
  | null {
  switch (event.type) {
    case 'INITIAL_PURCHASE':
    case 'RENEWAL':
    case 'UNCANCELLATION':
    case 'PRODUCT_CHANGE':
    case 'SUBSCRIPTION_EXTENDED':
    case 'TEMPORARY_ENTITLEMENT_GRANT':
      return { is_pro: 1, pro_expires_at: event.expiration_at_ms ?? null };
    case 'CANCELLATION':
      // A normal cancel keeps Pro until it expires. A refund ends it now.
      if (event.cancel_reason === 'CUSTOMER_SUPPORT') return { is_pro: 0, pro_expires_at: now };
      return { is_pro: 1, pro_expires_at: event.expiration_at_ms ?? null };
    case 'EXPIRATION':
      return { is_pro: 0, pro_expires_at: event.expiration_at_ms ?? now };
    default:
      return null;
  }
}

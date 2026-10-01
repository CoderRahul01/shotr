import { describe, expect, it } from 'vitest';

import { accountView, decide, proFromRevenueCat, type UserRecord } from '../src/quota';

const cfg = { freeMakes: 5, proMonthlyMakes: 300 };
const now = Date.UTC(2026, 9, 1);
const free = (used: number): UserRecord => ({ is_pro: 0, pro_expires_at: null, free_used: used });
const pro: UserRecord = { is_pro: 1, pro_expires_at: now + 86_400_000, free_used: 5 };

const base = { monthUsed: 0, regenUsedForShot: false, hasPreviousDraft: false, config: cfg, now };

describe('decide', () => {
  it('free users get 5 makes', () => {
    expect(decide({ ...base, user: free(4), kind: 'make' })).toEqual({ allowed: true, charge: true, freeRegen: false });
    expect(decide({ ...base, user: free(5), kind: 'make' })).toEqual({ allowed: false, reason: 'free_used' });
  });

  it('tweaks never count', () => {
    expect(decide({ ...base, user: free(5), kind: 'tweak', hasPreviousDraft: true })).toEqual({ allowed: true, charge: false, freeRegen: false });
  });

  it('first regenerate per shot is free, the second counts', () => {
    expect(decide({ ...base, user: free(5), kind: 'regenerate', hasPreviousDraft: true })).toEqual({ allowed: true, charge: false, freeRegen: true });
    expect(decide({ ...base, user: free(5), kind: 'regenerate', hasPreviousDraft: true, regenUsedForShot: true })).toEqual({ allowed: false, reason: 'free_used' });
  });

  it('tweak and regenerate need a draft', () => {
    expect(decide({ ...base, user: free(0), kind: 'tweak' })).toEqual({ allowed: false, reason: 'needs_draft' });
  });

  it('pro has a monthly fair-use cap', () => {
    expect(decide({ ...base, user: pro, kind: 'make', monthUsed: 299 })).toMatchObject({ allowed: true });
    expect(decide({ ...base, user: pro, kind: 'make', monthUsed: 300 })).toEqual({ allowed: false, reason: 'fair_use' });
  });

  it('expired pro falls back to free rules', () => {
    const expired = { ...pro, pro_expires_at: now - 1 };
    expect(decide({ ...base, user: expired, kind: 'make' })).toEqual({ allowed: false, reason: 'free_used' });
  });
});

describe('accountView', () => {
  it('reports free makes left and pro allowance', () => {
    expect(accountView(free(3), 0, cfg, now)).toEqual({ is_pro: false, free_makes_left: 2, free_makes_total: 5, monthly_makes_left: null });
    expect(accountView(pro, 10, cfg, now)).toMatchObject({ is_pro: true, monthly_makes_left: 290 });
  });
});

describe('RevenueCat events', () => {
  it('purchase and renewal turn Pro on', () => {
    expect(proFromRevenueCat({ type: 'INITIAL_PURCHASE', expiration_at_ms: 123 }, now)).toEqual({ is_pro: 1, pro_expires_at: 123 });
  });
  it('normal cancel keeps Pro until expiry, refund ends it now', () => {
    expect(proFromRevenueCat({ type: 'CANCELLATION', expiration_at_ms: 999 }, now)).toEqual({ is_pro: 1, pro_expires_at: 999 });
    expect(proFromRevenueCat({ type: 'CANCELLATION', cancel_reason: 'CUSTOMER_SUPPORT' }, now)).toEqual({ is_pro: 0, pro_expires_at: now });
  });
  it('expiration turns Pro off; unknown events are ignored', () => {
    expect(proFromRevenueCat({ type: 'EXPIRATION' }, now)).toEqual({ is_pro: 0, pro_expires_at: now });
    expect(proFromRevenueCat({ type: 'TEST' }, now)).toBeNull();
  });
});

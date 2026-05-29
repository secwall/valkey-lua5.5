/*
 * Copyright (c) Valkey Contributors
 * All rights reserved.
 * SPDX-License-Identifier: BSD-3-Clause
 */

#include <stdint.h>
#include <stdio.h>
#include <string.h>

#include "lauxlib.h"
#include "lua.h"

static int32_t bit_checki32(lua_State *L, int idx) {
  lua_Integer v = luaL_checkinteger(L, idx);
  return (int32_t)(uint32_t)v;
}

static int32_t bit_opti32(lua_State *L, int idx, int32_t def) {
  if (lua_isnoneornil(L, idx))
    return def;
  return bit_checki32(L, idx);
}

static int b_tobit(lua_State *L) {
  lua_pushinteger(L, (lua_Integer)bit_checki32(L, 1));
  return 1;
}

static int b_bnot(lua_State *L) {
  uint32_t x = (uint32_t)bit_checki32(L, 1);
  lua_pushinteger(L, (lua_Integer)(int32_t)(~x));
  return 1;
}

static int b_band(lua_State *L) {
  int n = lua_gettop(L);
  if (n == 0) {
    lua_pushinteger(L, (lua_Integer)(int32_t)0xffffffffu);
    return 1;
  }
  uint32_t r = (uint32_t)bit_checki32(L, 1);
  for (int i = 2; i <= n; i++)
    r &= (uint32_t)bit_checki32(L, i);
  lua_pushinteger(L, (lua_Integer)(int32_t)r);
  return 1;
}

static int b_bor(lua_State *L) {
  int n = lua_gettop(L);
  uint32_t r = 0;
  for (int i = 1; i <= n; i++)
    r |= (uint32_t)bit_checki32(L, i);
  lua_pushinteger(L, (lua_Integer)(int32_t)r);
  return 1;
}

static int b_bxor(lua_State *L) {
  int n = lua_gettop(L);
  uint32_t r = 0;
  for (int i = 1; i <= n; i++)
    r ^= (uint32_t)bit_checki32(L, i);
  lua_pushinteger(L, (lua_Integer)(int32_t)r);
  return 1;
}

static int b_lshift(lua_State *L) {
  uint32_t x = (uint32_t)bit_checki32(L, 1);
  unsigned n = (unsigned)(bit_checki32(L, 2)) & 31u;
  lua_pushinteger(L, (lua_Integer)(int32_t)(x << n));
  return 1;
}

static int b_rshift(lua_State *L) {
  uint32_t x = (uint32_t)bit_checki32(L, 1);
  unsigned n = (unsigned)(bit_checki32(L, 2)) & 31u;
  lua_pushinteger(L, (lua_Integer)(int32_t)(x >> n));
  return 1;
}

static int b_arshift(lua_State *L) {
  int32_t x = bit_checki32(L, 1);
  unsigned n = (unsigned)(bit_checki32(L, 2)) & 31u;
  int32_t r = x >> n;
  lua_pushinteger(L, (lua_Integer)r);
  return 1;
}

static int b_rol(lua_State *L) {
  uint32_t x = (uint32_t)bit_checki32(L, 1);
  unsigned n = (unsigned)(bit_checki32(L, 2)) & 31u;
  uint32_t r = (n == 0) ? x : ((x << n) | (x >> (32u - n)));
  lua_pushinteger(L, (lua_Integer)(int32_t)r);
  return 1;
}

static int b_ror(lua_State *L) {
  uint32_t x = (uint32_t)bit_checki32(L, 1);
  unsigned n = (unsigned)(bit_checki32(L, 2)) & 31u;
  uint32_t r = (n == 0) ? x : ((x >> n) | (x << (32u - n)));
  lua_pushinteger(L, (lua_Integer)(int32_t)r);
  return 1;
}

static int b_bswap(lua_State *L) {
  uint32_t x = (uint32_t)bit_checki32(L, 1);
  uint32_t r = ((x & 0xffu) << 24) | ((x & 0xff00u) << 8) |
               ((x & 0xff0000u) >> 8) | ((x & 0xff000000u) >> 24);
  lua_pushinteger(L, (lua_Integer)(int32_t)r);
  return 1;
}

static int b_tohex(lua_State *L) {
  int32_t x = bit_checki32(L, 1);
  int32_t n_signed = bit_opti32(L, 2, 8);

  int uppercase = 0;
  uint32_t n_abs;
  if (n_signed < 0) {
    uppercase = 1;
    n_abs = (uint32_t)(-(int64_t)n_signed);
  } else {
    n_abs = (uint32_t)n_signed;
  }
  if (n_abs == 0) {
    lua_pushliteral(L, "");
    return 1;
  }
  if (n_abs > 8)
    n_abs = 8;

  char buf[16];
  int written = snprintf(buf, sizeof(buf), uppercase ? "%08X" : "%08x",
                         (unsigned)(uint32_t)x);
  (void)written;
  lua_pushlstring(L, buf + (8 - (int)n_abs), (size_t)n_abs);
  return 1;
}

static const luaL_Reg bit_lib[] = {
    {"tobit", b_tobit},   {"bnot", b_bnot},       {"band", b_band},
    {"bor", b_bor},       {"bxor", b_bxor},       {"lshift", b_lshift},
    {"rshift", b_rshift}, {"arshift", b_arshift}, {"rol", b_rol},
    {"ror", b_ror},       {"bswap", b_bswap},     {"tohex", b_tohex},
    {NULL, NULL},
};

int luaopen_bit(lua_State *L) {
  luaL_newlib(L, bit_lib);
  return 1;
}

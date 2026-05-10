// ignore_for_file: duplicate_ignore, constant_identifier_names, unused_import

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// ── Complete algorithm dataset (OLL:57, PLL:21, F2L:41, 2x2, Pyraminx, Skewb) ──
// Source: jperm.net / cubing.net
// level: 0=Beginner, 1=Advanced, 2=Expert
// ollMap: bitfield of 9 top stickers (0=grey/unoriented, 1=yellow) for OLL cases
const _algs = <Map<String, dynamic>>[
// ── F2L (41 cases) ─────────────────────────────────────────────────────────────
  {
    'cat': 'F2L',
    'name': 'F2L 1',
    'alg': "U R U' R'",
    'level': 0,
    'desc': 'Corner in top, edge in top - paired'
  },
  {
    'cat': 'F2L',
    'name': 'F2L 2',
    'alg': "U' F' U F",
    'level': 0,
    'desc': 'Mirror of F2L 1'
  },
  {
    'cat': 'F2L',
    'name': 'F2L 3',
    'alg': "R U' R' U R U' R'",
    'level': 0,
    'desc': 'Corner right, edge top'
  },
  {
    'cat': 'F2L',
    'name': 'F2L 4',
    'alg': "F' U F U' F' U F",
    'level': 0,
    'desc': 'Corner front, edge top'
  },
  {
    'cat': 'F2L',
    'name': 'F2L 5',
    'alg': "R U R' U' R U R'",
    'level': 0,
    'desc': 'Both in top, wrong orientation'
  },
  {
    'cat': 'F2L',
    'name': 'F2L 6',
    'alg': "F' U' F U F' U' F",
    'level': 0,
    'desc': 'Mirror of F2L 5'
  },
  {
    'cat': 'F2L',
    'name': 'F2L 7',
    'alg': "U R U2' R' U R U' R'",
    'level': 1,
    'desc': 'Corner up, edge in slot'
  },
  {
    'cat': 'F2L',
    'name': 'F2L 8',
    'alg': "U' F' U2 F U' F' U F",
    'level': 1,
    'desc': 'Mirror of F2L 7'
  },
  {
    'cat': 'F2L',
    'name': 'F2L 9',
    'alg': "R U2' R' U' R U R'",
    'level': 1,
    'desc': 'Corner up flipped'
  },
  {
    'cat': 'F2L',
    'name': 'F2L 10',
    'alg': "F' U2 F U F' U' F",
    'level': 1,
    'desc': 'Mirror F2L 9'
  },
  {
    'cat': 'F2L',
    'name': 'F2L 11',
    'alg': "R U' R' U2 R U' R'",
    'level': 1,
    'desc': 'Edge in slot, corner in top'
  },
  {
    'cat': 'F2L',
    'name': 'F2L 12',
    'alg': "F' U F U2' F' U F",
    'level': 1,
    'desc': 'Mirror F2L 11'
  },
  {
    'cat': 'F2L',
    'name': 'F2L 13',
    'alg': "U' R U R' U R U' R'",
    'level': 1,
    'desc': 'Corner top, edge slot connected'
  },
  {
    'cat': 'F2L',
    'name': 'F2L 14',
    'alg': "U F' U' F U' F' U F",
    'level': 1,
    'desc': 'Mirror F2L 13'
  },
  {
    'cat': 'F2L',
    'name': 'F2L 15',
    'alg': "R U' R' U' R U R'",
    'level': 1,
    'desc': 'Connected pair, wrong place'
  },
  {
    'cat': 'F2L',
    'name': 'F2L 16',
    'alg': "F' U F U F' U' F",
    'level': 1,
    'desc': 'Mirror F2L 15'
  },
  {
    'cat': 'F2L',
    'name': 'F2L 17',
    'alg': "R U R' U' R U R' U' R U R'",
    'level': 1,
    'desc': 'Triple sexy move'
  },
  {
    'cat': 'F2L',
    'name': 'F2L 18',
    'alg': "F' U' F U F' U' F U F' U' F",
    'level': 1,
    'desc': 'Mirror F2L 17'
  },
  {
    'cat': 'F2L',
    'name': 'F2L 19',
    'alg': "U R U' R' U' F' U F",
    'level': 1,
    'desc': 'Slot empty, pieces in top'
  },
  {
    'cat': 'F2L',
    'name': 'F2L 20',
    'alg': "U' F' U F U R U' R'",
    'level': 1,
    'desc': 'Mirror F2L 19'
  },
  {
    'cat': 'F2L',
    'name': 'F2L 21',
    'alg': "R U' R' U R U' R' U R U' R'",
    'level': 2,
    'desc': 'Corner in slot wrong'
  },
  {
    'cat': 'F2L',
    'name': 'F2L 22',
    'alg': "F' U F U' F' U F U' F' U F",
    'level': 2,
    'desc': 'Mirror F2L 21'
  },
  {
    'cat': 'F2L',
    'name': 'F2L 23',
    'alg': "R U R' U2' R U' R'",
    'level': 1,
    'desc': 'Edge in slot, corner top flipped'
  },
  {
    'cat': 'F2L',
    'name': 'F2L 24',
    'alg': "F' U' F U2 F' U F",
    'level': 1,
    'desc': 'Mirror F2L 23'
  },
  {
    'cat': 'F2L',
    'name': 'F2L 25',
    'alg': "R U' R' U F' U' F",
    'level': 1,
    'desc': 'Both pieces top, no pair'
  },
  {
    'cat': 'F2L',
    'name': 'F2L 26',
    'alg': "F' U F U' R U R'",
    'level': 1,
    'desc': 'Mirror F2L 25'
  },
  {
    'cat': 'F2L',
    'name': 'F2L 27',
    'alg': "R U' R' U R U2' R' U R U' R'",
    'level': 2,
    'desc': 'All wrong'
  },
  {
    'cat': 'F2L',
    'name': 'F2L 28',
    'alg': "F' U F U' F' U2 F U' F' U F",
    'level': 2,
    'desc': 'Mirror F2L 27'
  },
  {
    'cat': 'F2L',
    'name': 'F2L 29',
    'alg': "U R U2' R' U2 R U' R'",
    'level': 2,
    'desc': 'Corner top, edge in slot flipped'
  },
  {
    'cat': 'F2L',
    'name': 'F2L 30',
    'alg': "U' F' U2 F U2' F' U F",
    'level': 2,
    'desc': 'Mirror F2L 29'
  },
  {
    'cat': 'F2L',
    'name': 'F2L 31',
    'alg': "R' U2 R U R' U' R",
    'level': 1,
    'desc': 'Corner in slot, edge top'
  },
  {
    'cat': 'F2L',
    'name': 'F2L 32',
    'alg': "F U2' F' U' F U F'",
    'level': 1,
    'desc': 'Mirror F2L 31'
  },
  {
    'cat': 'F2L',
    'name': 'F2L 33',
    'alg': "U' R U' R' U2 R U' R'",
    'level': 2,
    'desc': 'Both in top adjacent'
  },
  {
    'cat': 'F2L',
    'name': 'F2L 34',
    'alg': "U F' U F U2' F' U F",
    'level': 2,
    'desc': 'Mirror F2L 33'
  },
  {
    'cat': 'F2L',
    'name': 'F2L 35',
    'alg': "R U R' U' R U' R' U2 R U' R'",
    'level': 2,
    'desc': 'Both wrong'
  },
  {
    'cat': 'F2L',
    'name': 'F2L 36',
    'alg': "F' U' F U F' U F U2' F' U F",
    'level': 2,
    'desc': 'Mirror F2L 35'
  },
  {
    'cat': 'F2L',
    'name': 'F2L 37',
    'alg': "R U R' U' R U R' U' R U R'",
    'level': 2,
    'desc': 'Sexy move x3'
  },
  {
    'cat': 'F2L',
    'name': 'F2L 38',
    'alg': "R U' R' d R' U' R U' R' U' R",
    'level': 2,
    'desc': 'Wide insert'
  },
  {
    'cat': 'F2L',
    'name': 'F2L 39',
    'alg': "R' F R F' R' F R F'",
    'level': 2,
    'desc': 'Edge flip with sledgehammer'
  },
  {
    'cat': 'F2L',
    'name': 'F2L 40',
    'alg': "R U' R' U' F' U F",
    'level': 1,
    'desc': 'Corner in slot edge top'
  },
  {
    'cat': 'F2L',
    'name': 'F2L 41',
    'alg': "R' F' R U R U' R' F",
    'level': 2,
    'desc': 'Weird edge case'
  },

// ── OLL (57 cases) ─────────────────────────────────────────────────────────────
// oll: 9 booleans [tl,tc,tr,ml,cc,mr,bl,bc,br] — cc(center) always true for 3x3
  {
    'cat': 'OLL',
    'name': 'OLL 1 (Dot)',
    'alg': "R U2' R2' F R F' U2' R' F R F'",
    'level': 2,
    'oll': '000000000',
    'desc': 'No edges oriented'
  },
  {
    'cat': 'OLL',
    'name': 'OLL 2 (Dot)',
    'alg': "F R U R' U' F' f R U R' U' f'",
    'level': 2,
    'oll': '000000000',
    'desc': 'Dot case 2'
  },
  {
    'cat': 'OLL',
    'name': 'OLL 3 (Dot)',
    'alg': "f R U R' U' f' U' F R U R' U' F'",
    'level': 2,
    'oll': '000000000',
    'desc': 'Dot case 3'
  },
  {
    'cat': 'OLL',
    'name': 'OLL 4 (Dot)',
    'alg': "f R U R' U' f' U F R U R' U' F'",
    'level': 2,
    'oll': '000000000',
    'desc': 'Dot case 4'
  },
  {
    'cat': 'OLL',
    'name': 'OLL 5 (Square)',
    'alg': "r' U2' R U R' U r",
    'level': 1,
    'oll': '110000000',
    'desc': 'Square shape front-left'
  },
  {
    'cat': 'OLL',
    'name': 'OLL 6 (Square)',
    'alg': "r U2 R' U' R U' r'",
    'level': 1,
    'oll': '011000000',
    'desc': 'Square shape front-right'
  },
  {
    'cat': 'OLL',
    'name': 'OLL 7 (S)',
    'alg': "r U R' U R U2' r'",
    'level': 1,
    'oll': '010010100',
    'desc': 'S shape'
  },
  {
    'cat': 'OLL',
    'name': 'OLL 8 (S)',
    'alg': "r' U' R U' R' U2 r",
    'level': 1,
    'oll': '001010010',
    'desc': 'S mirror'
  },
  {
    'cat': 'OLL',
    'name': 'OLL 9 (Fish)',
    'alg': "R U R' U' R' F R2 U R' U' F'",
    'level': 1,
    'oll': '000010110',
    'desc': 'Fish front-right'
  },
  {
    'cat': 'OLL',
    'name': 'OLL 10 (Fish)',
    'alg': "R U R' U R' F R F' R U2' R'",
    'level': 1,
    'oll': '011010000',
    'desc': 'Fish front-left'
  },
  {
    'cat': 'OLL',
    'name': 'OLL 11 (Small L)',
    'alg': "r' R2 U R' U R U2' R' U M'",
    'level': 1,
    'oll': '000010011',
    'desc': 'Small L'
  },
  {
    'cat': 'OLL',
    'name': 'OLL 12 (Small L)',
    'alg': "M' R' U' R U' R' U2 R U' M",
    'level': 1,
    'oll': '110010000',
    'desc': 'Small L mirror'
  },
  {
    'cat': 'OLL',
    'name': 'OLL 13 (Knight)',
    'alg': "F U R U' R2' F' R U R U' R'",
    'level': 2,
    'oll': '000110100',
    'desc': 'Knight move shape'
  },
  {
    'cat': 'OLL',
    'name': 'OLL 14 (Knight)',
    'alg': "R' F R U R' F' R F U' F'",
    'level': 2,
    'oll': '001011000',
    'desc': 'Knight mirror'
  },
  {
    'cat': 'OLL',
    'name': 'OLL 15 (Knight)',
    'alg': "r' U' r R' U' R U r' U r",
    'level': 2,
    'oll': '000111000',
    'desc': 'Knight variation'
  },
  {
    'cat': 'OLL',
    'name': 'OLL 16 (Knight)',
    'alg': "r U r' R U R' U' r U' r'",
    'level': 2,
    'oll': '000111000',
    'desc': 'Knight var 2'
  },
  {
    'cat': 'OLL',
    'name': 'OLL 17',
    'alg': "R U R' U R' F R F' U2' R' F R F'",
    'level': 2,
    'oll': '010110010',
    'desc': ''
  },
  {
    'cat': 'OLL',
    'name': 'OLL 18',
    'alg': "r U R' U R U2' r2' U' R U' R' U2 r",
    'level': 2,
    'oll': '011010010',
    'desc': ''
  },
  {
    'cat': 'OLL',
    'name': 'OLL 19',
    'alg': "r' R U R U R' U' r2 R2' U R U' r'",
    'level': 2,
    'oll': '010010011',
    'desc': ''
  },
  {
    'cat': 'OLL',
    'name': 'OLL 20 (X)',
    'alg': "r U R' U' r' F R F' R U R' U' R' F R F'",
    'level': 2,
    'oll': '010010010',
    'desc': 'X/Bow-tie'
  },
  {
    'cat': 'OLL',
    'name': 'OLL 21 (H)',
    'alg': "R U R' U R U' R' U R U2' R'",
    'level': 0,
    'oll': '010111010',
    'desc': 'H shape - most common beginner case'
  },
  {
    'cat': 'OLL',
    'name': 'OLL 22 (Pi)',
    'alg': "R U2' R2' U' R2 U' R2' U2' R",
    'level': 0,
    'oll': '010010010',
    'desc': 'Pi shape'
  },
  {
    'cat': 'OLL',
    'name': 'OLL 23 (Sune)',
    'alg': "R U R' U R U2' R'",
    'level': 0,
    'oll': '001010110',
    'desc': 'Sune - most recognised OLL'
  },
  {
    'cat': 'OLL',
    'name': 'OLL 24 (Anti-Sune)',
    'alg': "R U2' R' U' R U' R'",
    'level': 0,
    'oll': '011010100',
    'desc': 'Anti-Sune'
  },
  {
    'cat': 'OLL',
    'name': 'OLL 25',
    'alg': "F' r U R' U' r' F R",
    'level': 1,
    'oll': '100010011',
    'desc': ''
  },
  {
    'cat': 'OLL',
    'name': 'OLL 26 (Antisune var)',
    'alg': "R' U' R U' R' U2' R",
    'level': 0,
    'oll': '010110100',
    'desc': 'Left Sune'
  },
  {
    'cat': 'OLL',
    'name': 'OLL 27 (Sune var)',
    'alg': "R U R' U R U2' R'",
    'level': 0,
    'oll': '001011010',
    'desc': 'Right Sune'
  },
  {
    'cat': 'OLL',
    'name': 'OLL 28',
    'alg': "r U R' U' r' R U R U' R'",
    'level': 1,
    'oll': '010010110',
    'desc': ''
  },
  {
    'cat': 'OLL',
    'name': 'OLL 29',
    'alg': "R U R' U' R U' R' F' U' F R U R'",
    'level': 2,
    'oll': '000111010',
    'desc': ''
  },
  {
    'cat': 'OLL',
    'name': 'OLL 30',
    'alg': "F R' F R2 U' R' U' R U R' F2'",
    'level': 2,
    'oll': '010111000',
    'desc': ''
  },
  {
    'cat': 'OLL',
    'name': 'OLL 31',
    'alg': "R' U' F U R U' R' F' R",
    'level': 1,
    'oll': '010100011',
    'desc': ''
  },
  {
    'cat': 'OLL',
    'name': 'OLL 32',
    'alg': "L U F' U' L' U L F L'",
    'level': 1,
    'oll': '110001010',
    'desc': ''
  },
  {
    'cat': 'OLL',
    'name': 'OLL 33 (T shape)',
    'alg': "R U R' U' R' F R F'",
    'level': 0,
    'oll': '010011100',
    'desc': 'T shape - very common'
  },
  {
    'cat': 'OLL',
    'name': 'OLL 34',
    'alg': "R U R2' U' R' F R U R U' F'",
    'level': 1,
    'oll': '001010110',
    'desc': ''
  },
  {
    'cat': 'OLL',
    'name': 'OLL 35',
    'alg': "R U2' R2' F R F' R U2' R'",
    'level': 1,
    'oll': '011011000',
    'desc': ''
  },
  {
    'cat': 'OLL',
    'name': 'OLL 36',
    'alg': "R' U' R U' R' U R U l U' R' U",
    'level': 2,
    'oll': '010110011',
    'desc': ''
  },
  {
    'cat': 'OLL',
    'name': 'OLL 37 (Fish)',
    'alg': "F R' F' R U R U' R'",
    'level': 1,
    'oll': '000011110',
    'desc': 'Fish shape top-right'
  },
  {
    'cat': 'OLL',
    'name': 'OLL 38',
    'alg': "R U R' U R U' R' U' R' F R F'",
    'level': 2,
    'oll': '100110010',
    'desc': ''
  },
  {
    'cat': 'OLL',
    'name': 'OLL 39 (Big fish)',
    'alg': "R' F R U R' U' F' U R",
    'level': 1,
    'oll': '100010110',
    'desc': ''
  },
  {
    'cat': 'OLL',
    'name': 'OLL 40 (Big fish)',
    'alg': "R U R' F' U' F R U R'",
    'level': 1,
    'oll': '011010001',
    'desc': ''
  },
  {
    'cat': 'OLL',
    'name': 'OLL 41 (L)',
    'alg': "R U' R' U2 R U y R U' R' U' F'",
    'level': 2,
    'oll': '011011010',
    'desc': ''
  },
  {
    'cat': 'OLL',
    'name': 'OLL 42 (L)',
    'alg': "R' U R U2' R' U' y' R' U R U F",
    'level': 2,
    'oll': '010110110',
    'desc': ''
  },
  {
    'cat': 'OLL',
    'name': 'OLL 43',
    'alg': "f' L' U' L U f",
    'level': 1,
    'oll': '001100010',
    'desc': ''
  },
  {
    'cat': 'OLL',
    'name': 'OLL 44 (T)',
    'alg': "f R U R' U' f'",
    'level': 0,
    'oll': '010001100',
    'desc': 'T shape variation'
  },
  {
    'cat': 'OLL',
    'name': 'OLL 45 (T)',
    'alg': "F R U R' U' F'",
    'level': 0,
    'oll': '010011010',
    'desc': 'Front T shape'
  },
  {
    'cat': 'OLL',
    'name': 'OLL 46',
    'alg': "R' U' R' F R F' U R",
    'level': 1,
    'oll': '010100110',
    'desc': ''
  },
  {
    'cat': 'OLL',
    'name': 'OLL 47 (Pi)',
    'alg': "F' L' U' L U L' U' L U F",
    'level': 1,
    'oll': '110011100',
    'desc': 'Pi variation'
  },
  {
    'cat': 'OLL',
    'name': 'OLL 48 (Pi)',
    'alg': "F R U R' U' R U R' U' F'",
    'level': 1,
    'oll': '001110001',
    'desc': 'Pi variation 2'
  },
  {
    'cat': 'OLL',
    'name': 'OLL 49 (Pi)',
    'alg': "r U2' R' U' R U' r' U r' U' R U' R' U2 r",
    'level': 2,
    'oll': '110111100',
    'desc': ''
  },
  {
    'cat': 'OLL',
    'name': 'OLL 50 (Pi)',
    'alg': "r' U2 R U R' U r U' r U R' U R U2' r'",
    'level': 2,
    'oll': '001111001',
    'desc': ''
  },
  {
    'cat': 'OLL',
    'name': 'OLL 51 (Bowtie)',
    'alg': "f R U R' U' R U R' U' f'",
    'level': 1,
    'oll': '000111000',
    'desc': 'Bow-tie'
  },
  {
    'cat': 'OLL',
    'name': 'OLL 52 (Bowtie)',
    'alg': "r U R' U R U' R' U R U2' r'",
    'level': 1,
    'oll': '010011100',
    'desc': ''
  },
  {
    'cat': 'OLL',
    'name': 'OLL 53 (Chameleon)',
    'alg': "l' U2 L U L' U l",
    'level': 1,
    'oll': '100011001',
    'desc': 'Chameleon'
  },
  {
    'cat': 'OLL',
    'name': 'OLL 54 (Chameleon)',
    'alg': "r U2' R' U' R U' r'",
    'level': 1,
    'oll': '100110001',
    'desc': 'Chameleon mirror'
  },
  {
    'cat': 'OLL',
    'name': 'OLL 55 (Bowtie)',
    'alg': "R' F R U R U' R2' F' R2 U' R' U R U R'",
    'level': 2,
    'oll': '011111010',
    'desc': ''
  },
  {
    'cat': 'OLL',
    'name': 'OLL 56 (Bowtie)',
    'alg': "r' U' r U' R' U R U' R' U R r' U r",
    'level': 2,
    'oll': '010111110',
    'desc': ''
  },
  {
    'cat': 'OLL',
    'name': 'OLL 57 (H)',
    'alg': "R U R' U' M' U R U' r'",
    'level': 1,
    'oll': '010111010',
    'desc': 'H shape with M-slice'
  },

// ── PLL (21 cases) ─────────────────────────────────────────────────────────────
  {
    'cat': 'PLL',
    'name': 'PLL - Skip',
    'alg': '(Skip)',
    'level': 0,
    'desc': 'Already solved!'
  },
  {
    'cat': 'PLL',
    'name': 'Ua',
    'alg': "R U' R U R U R U' R' U' R2",
    'level': 0,
    'desc': '3 edges cycle CW'
  },
  {
    'cat': 'PLL',
    'name': 'Ub',
    'alg': "R2 U R U R' U' R' U' R' U R'",
    'level': 0,
    'desc': '3 edges cycle CCW'
  },
  {
    'cat': 'PLL',
    'name': 'H',
    'alg': "M2' U M2' U2' M2' U M2'",
    'level': 0,
    'desc': 'Opposite edges swap x2'
  },
  {
    'cat': 'PLL',
    'name': 'Z',
    'alg': "M2' U M2' U M' U2' M2' U2' M'",
    'level': 0,
    'desc': 'Adjacent edges swap x2'
  },
  {
    'cat': 'PLL',
    'name': 'T',
    'alg': "R U R' U' R' F R2 U' R' U' R U R' F'",
    'level': 0,
    'desc': 'Swap 2 corners + 2 edges'
  },
  {
    'cat': 'PLL',
    'name': 'Y',
    'alg': "F R U' R' U' R U R' F' R U R' U' R' F R F'",
    'level': 1,
    'desc': 'Diagonal swap'
  },
  {
    'cat': 'PLL',
    'name': 'F',
    'alg': "R' U' F' R U R' U' R' F R2 U' R' U' R U R' U R",
    'level': 1,
    'desc': ''
  },
  {
    'cat': 'PLL',
    'name': 'Aa',
    'alg': "x R' U R' D2 R U' R' D2 R2 x'",
    'level': 1,
    'desc': '3 corners cycle CW'
  },
  {
    'cat': 'PLL',
    'name': 'Ab',
    'alg': "x R2 D2 R U R' D2 R U' R x'",
    'level': 1,
    'desc': '3 corners cycle CCW'
  },
  {
    'cat': 'PLL',
    'name': 'Ja',
    'alg': "x R2 F R F' R U2' r' U r U2' x'",
    'level': 1,
    'desc': ''
  },
  {
    'cat': 'PLL',
    'name': 'Jb',
    'alg': "R U R' F' R U R' U' R' F R2 U' R'",
    'level': 1,
    'desc': ''
  },
  {
    'cat': 'PLL',
    'name': 'Ra',
    'alg': "R U R' F' R U2' R' U2' R' F R U R U2' R'",
    'level': 1,
    'desc': ''
  },
  {
    'cat': 'PLL',
    'name': 'Rb',
    'alg': "R' U2 R U2' R' F R U R' U' R' F' R2",
    'level': 1,
    'desc': ''
  },
  {
    'cat': 'PLL',
    'name': 'V',
    'alg': "R' U R' d' R' F' R2 U' R' U R' F R F",
    'level': 2,
    'desc': ''
  },
  {
    'cat': 'PLL',
    'name': 'Na',
    'alg': "R U R' U R U R' F' R U R' U' R' F R2 U' R' U2 R U' R'",
    'level': 2,
    'desc': 'Longest PLL'
  },
  {
    'cat': 'PLL',
    'name': 'Nb',
    'alg': "R' U L' U2 R U' L R' U L' U2 R U' L",
    'level': 2,
    'desc': 'N-perm mirror'
  },
  {
    'cat': 'PLL',
    'name': 'E',
    'alg': "x' R U' R' D R U R' D' R U R' D R U' R' D' x",
    'level': 2,
    'desc': 'Opposite corners swap'
  },
  {
    'cat': 'PLL',
    'name': 'Ga',
    'alg': "R2 U R' U R' U' R U' R2 D U' R' U R D'",
    'level': 2,
    'desc': 'G-perm CW'
  },
  {
    'cat': 'PLL',
    'name': 'Gb',
    'alg': "R' U' R U D' R2 U R' U R U' R U' R2 D",
    'level': 2,
    'desc': 'G-perm CCW'
  },
  {
    'cat': 'PLL',
    'name': 'Gc',
    'alg': "R2 F2 R U2 R U2' R' F R U R' U' R' F R2",
    'level': 2,
    'desc': ''
  },
  {
    'cat': 'PLL',
    'name': 'Gd',
    'alg': "R U R' U' D R2 U' R U' R' U R' U R2 D'",
    'level': 2,
    'desc': ''
  },

// ── 2x2 ────────────────────────────────────────────────────────────────────────
  {
    'cat': '2x2',
    'name': 'OLL - Skip',
    'alg': '(Skip)',
    'level': 0,
    'desc': 'Top already oriented'
  },
  {
    'cat': '2x2',
    'name': 'OLL 1 (Sune)',
    'alg': "R U R' U R U2' R'",
    'level': 0,
    'desc': 'Sune'
  },
  {
    'cat': '2x2',
    'name': 'OLL 2 (Anti-Sune)',
    'alg': "R U2' R' U' R U' R'",
    'level': 0,
    'desc': 'Anti-Sune'
  },
  {
    'cat': '2x2',
    'name': 'OLL 3 (H)',
    'alg': "F R U R' U' F'",
    'level': 0,
    'desc': '2 headlights'
  },
  {
    'cat': '2x2',
    'name': 'OLL 4 (Pi)',
    'alg': "R U2' R' U' R U' R' F R U R' U' F'",
    'level': 1,
    'desc': 'Pi / 4 diagonal'
  },
  {
    'cat': '2x2',
    'name': 'OLL 5 (S)',
    'alg': "F' r U R' U' r' F R",
    'level': 1,
    'desc': 'S shape'
  },
  {
    'cat': '2x2',
    'name': 'OLL 6 (S mirror)',
    'alg': "f R U R' U' f'",
    'level': 1,
    'desc': 'S mirror'
  },
  {
    'cat': '2x2',
    'name': 'OLL 7 (L)',
    'alg': "F R' F' r U R U' r'",
    'level': 1,
    'desc': 'L shape'
  },
  {
    'cat': '2x2',
    'name': 'PBL Ua',
    'alg': "R U' R U R U R U' R' U' R2",
    'level': 0,
    'desc': 'U-perm CW'
  },
  {
    'cat': '2x2',
    'name': 'PBL Ub',
    'alg': "R2 U R U R' U' R' U' R' U R'",
    'level': 0,
    'desc': 'U-perm CCW'
  },
  {
    'cat': '2x2',
    'name': 'PBL H',
    'alg': "R2 U2 R2 U2 R2",
    'level': 0,
    'desc': 'Headlights on both'
  },
  {
    'cat': '2x2',
    'name': 'PBL Z',
    'alg': "R U R' U R U' R' U' R' F R F'",
    'level': 1,
    'desc': 'Z-perm 2x2'
  },
  {
    'cat': '2x2',
    'name': 'PBL Aa',
    'alg': "x R' U R' D2 R U' R' D2 R2",
    'level': 1,
    'desc': 'A-perm CW'
  },
  {
    'cat': '2x2',
    'name': 'PBL Ab',
    'alg': "x R2 D2 R U R' D2 R U' R",
    'level': 1,
    'desc': 'A-perm CCW'
  },
  {
    'cat': '2x2',
    'name': 'CLL U-front',
    'alg': "R U' R' U' R U R' F' R U R' U' R' F R",
    'level': 2,
    'desc': 'CLL: U face adj corner'
  },

// ── Pyraminx ────────────────────────────────────────────────────────────────────
  {
    'cat': 'Pyraminx',
    'name': 'Solved',
    'alg': '(Solved)',
    'level': 0,
    'desc': 'Already solved'
  },
  {
    'cat': 'Pyraminx',
    'name': 'L4E 1',
    'alg': "R U R' U R U2' R' U",
    'level': 0,
    'desc': '3 edges cycle'
  },
  {
    'cat': 'Pyraminx',
    'name': 'L4E 2',
    'alg': "U' R U' R' U R' U R",
    'level': 0,
    'desc': '3 edges CCW'
  },
  {
    'cat': 'Pyraminx',
    'name': 'L4E 3',
    'alg': "R U R' U' R U R'",
    'level': 0,
    'desc': 'Edge flip + cycle'
  },
  {
    'cat': 'Pyraminx',
    'name': 'L4E 4',
    'alg': "R' U R U' R' U' R",
    'level': 0,
    'desc': 'Mirror L4E 3'
  },
  {
    'cat': 'Pyraminx',
    'name': 'L4E 5',
    'alg': "U R U' R U' R' U R'",
    'level': 1,
    'desc': 'Adjacent edge swap'
  },
  {
    'cat': 'Pyraminx',
    'name': 'L4E 6',
    'alg': "R' U R' U R U' R' U R U' R",
    'level': 1,
    'desc': ''
  },
  {
    'cat': 'Pyraminx',
    'name': 'L4E 7',
    'alg': "U R U R' U R' U' R",
    'level': 1,
    'desc': ''
  },

// ── Skewb ────────────────────────────────────────────────────────────────────
  {
    'cat': 'Skewb',
    'name': 'Sarah Adj',
    'alg': "R' L R L' R' L R L'",
    'level': 0,
    'desc': 'Adjacent corner swap'
  },
  {
    'cat': 'Skewb',
    'name': 'Sarah Diag',
    'alg': "R L' R' L R L' R' L",
    'level': 0,
    'desc': 'Diagonal corner swap'
  },
  {
    'cat': 'Skewb',
    'name': '3 corners CW',
    'alg': "R' L R L' y R' L R L'",
    'level': 1,
    'desc': '3 top corners cycle'
  },
  {
    'cat': 'Skewb',
    'name': '3 corners CCW',
    'alg': "L R' L' R y L R' L' R",
    'level': 1,
    'desc': 'Mirror 3-cycle'
  },
  {
    'cat': 'Skewb',
    'name': 'Centers + corners',
    'alg': "R L R L R L",
    'level': 1,
    'desc': 'Cycle centers'
  },
];

const _levels = ['Principiante', 'Avanzato', 'Expert'];
const _levelColors = [Color(0xFF30D158), Color(0xFFFF9F0A), Color(0xFFFF453A)];

class AlgorithmsScreen extends StatefulWidget {
  const AlgorithmsScreen({super.key});
  @override
  State<AlgorithmsScreen> createState() => _AlgState();
}

class _AlgState extends State<AlgorithmsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tab;
  String _search = '';
  int? _levelFilter;
  final _searchCtrl = TextEditingController();

  static const _cats = ['F2L', 'OLL', 'PLL', '2x2', 'Pyraminx', 'Skewb'];

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: _cats.length, vsync: this);
  }

  @override
  void dispose() {
    _tab.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> _filtered(String cat) => _algs.where((a) {
        if (a['cat'] != cat) return false;
        if (_levelFilter != null && a['level'] != _levelFilter) return false;
        if (_search.isNotEmpty) {
          final q = _search.toLowerCase();
          return (a['name'] as String).toLowerCase().contains(q) ||
              (a['alg'] as String).toLowerCase().contains(q) ||
              (a['desc'] as String? ?? '').toLowerCase().contains(q);
        }
        return true;
      }).toList();

  @override
  Widget build(BuildContext context) {
    final th = Theme.of(context);
    final accent = th.colorScheme.primary;
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
          title: const Text('Algoritmi'),
          bottom: TabBar(
              controller: _tab,
              isScrollable: true,
              labelColor: accent,
              unselectedLabelColor:
                  th.colorScheme.onSurface.withValues(alpha: 0.5),
              indicatorColor: accent,
              tabs: _cats.map((c) => Tab(text: c)).toList())),
      body: Column(children: [
        Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
            child: Row(children: [
              Expanded(
                  child: TextField(
                      controller: _searchCtrl,
                      onChanged: (v) => setState(() => _search = v),
                      decoration: InputDecoration(
                          hintText: 'Cerca algoritmo...',
                          prefixIcon: const Icon(Icons.search, size: 18),
                          suffixIcon: _search.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear, size: 16),
                                  onPressed: () {
                                    _searchCtrl.clear();
                                    setState(() => _search = '');
                                  })
                              : null))),
              const SizedBox(width: 8),
              PopupMenuButton<int?>(
                  icon: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                          color: _levelFilter != null
                              ? _levelColors[_levelFilter!]
                                  .withValues(alpha: 0.12)
                              : th.cardColor,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: th.dividerColor)),
                      child: Text(
                          _levelFilter != null
                              ? _levels[_levelFilter!]
                              : 'Livello',
                          style: TextStyle(
                              fontSize: 12,
                              color: _levelFilter != null
                                  ? _levelColors[_levelFilter!]
                                  : th.colorScheme.onSurface))),
                  onSelected: (v) => setState(() => _levelFilter = v),
                  itemBuilder: (_) => [
                        const PopupMenuItem(value: null, child: Text('Tutti')),
                        ...List.generate(
                            3,
                            (i) => PopupMenuItem(
                                value: i,
                                child: Row(children: [
                                  Container(
                                      width: 10,
                                      height: 10,
                                      decoration: BoxDecoration(
                                          color: _levelColors[i],
                                          shape: BoxShape.circle)),
                                  const SizedBox(width: 8),
                                  Text(_levels[i]),
                                ]))),
                      ]),
            ])),
        Expanded(
            child: TabBarView(
                controller: _tab,
                children: _cats.map((cat) {
                  final algs = _filtered(cat);
                  if (algs.isEmpty)
                    return Center(
                        child: Text('Nessun algoritmo',
                            style: th.textTheme.bodyMedium));
                  return ListView.builder(
                      padding: const EdgeInsets.fromLTRB(12, 4, 12, 80),
                      itemCount: algs.length,
                      itemBuilder: (_, i) =>
                          _AlgCard(alg: algs[i], theme: th, accent: accent));
                }).toList())),
      ]),
    );
  }
}

class _AlgCard extends StatefulWidget {
  final Map<String, dynamic> alg;
  final ThemeData theme;
  final Color accent;
  const _AlgCard(
      {required this.alg, required this.theme, required this.accent});
  @override
  State<_AlgCard> createState() => _AlgCardState();
}

class _AlgCardState extends State<_AlgCard> {
  bool _expanded = false;
  @override
  Widget build(BuildContext context) {
    final a = widget.alg;
    final th = widget.theme;
    final accent = widget.accent;
    final lvl = a['level'] as int;
    return GestureDetector(
        onTap: () => setState(() => _expanded = !_expanded),
        child: Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(13),
            decoration: BoxDecoration(
                color: th.cardColor,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: th.dividerColor)),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                        color: _levelColors[lvl], shape: BoxShape.circle)),
                const SizedBox(width: 8),
                Expanded(
                    child: Text(a['name'],
                        style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                            color: th.colorScheme.onSurface))),
                Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                        color: _levelColors[lvl].withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8)),
                    child: Text(_levels[lvl],
                        style: TextStyle(
                            fontSize: 10,
                            color: _levelColors[lvl],
                            fontWeight: FontWeight.w700))),
                const SizedBox(width: 6),
                Icon(_expanded ? Icons.expand_less : Icons.expand_more,
                    size: 16,
                    color: th.colorScheme.onSurface.withValues(alpha: 0.4)),
              ]),
              const SizedBox(height: 6),
              Row(children: [
                Expanded(
                    child: Text(a['alg'],
                        style: const TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 13,
                            color: Color(0xFF6C63FF),
                            letterSpacing: 0.3))),
                InkWell(
                    onTap: () {
                      Clipboard.setData(ClipboardData(text: a['alg']));
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: const Text('Copiato!'),
                          duration: const Duration(seconds: 1),
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12))));
                    },
                    child: Icon(Icons.copy_outlined,
                        size: 15,
                        color:
                            th.colorScheme.onSurface.withValues(alpha: 0.35))),
              ]),
              if (_expanded) ...[
                const SizedBox(height: 10),
                // Visual case diagram
                if (a['cat'] == 'OLL' && a['oll'] != null)
                  _OllDiagram(ollStr: a['oll'] as String, accent: accent),
                if (a['cat'] == 'PLL')
                  _PllDiagram(name: a['name'], accent: accent),
                if ((a['desc'] as String? ?? '').isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(a['desc'],
                      style: th.textTheme.bodyMedium?.copyWith(fontSize: 12)),
                ],
              ],
            ])));
  }
}

// ── OLL Diagram: 3x3 top face with sticker orientation ────────
// ── OLL Diagram: top face 3x3 grid + edge sticker indicators ──────────
// Shows orientation: yellow=oriented, grey=needs flipping
// Edge stickers on the 4 sides show which edge pieces face up
class _OllDiagram extends StatelessWidget {
  final String ollStr;
  final Color accent;
  const _OllDiagram({required this.ollStr, required this.accent});
  @override
  Widget build(BuildContext context) {
    final th = Theme.of(context);
    return Row(children: [
      SizedBox(
          width: 80,
          height: 80,
          child: CustomPaint(painter: _OllPainter(ollStr))),
      const SizedBox(width: 10),
      Expanded(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Vista top (OLL)',
            style: th.textTheme.bodyMedium?.copyWith(
                fontSize: 10,
                color: th.colorScheme.onSurface.withValues(alpha: 0.5))),
        const SizedBox(height: 4),
        Row(children: [
          Container(width: 12, height: 12, color: const Color(0xFFFFD500)),
          const SizedBox(width: 4),
          Text('Orientato',
              style: th.textTheme.bodyMedium?.copyWith(fontSize: 10)),
        ]),
        const SizedBox(height: 2),
        Row(children: [
          Container(width: 12, height: 12, color: const Color(0xFF555555)),
          const SizedBox(width: 4),
          Text('Da girare',
              style: th.textTheme.bodyMedium?.copyWith(fontSize: 10)),
        ]),
        const SizedBox(height: 2),
        Row(children: [
          Container(
              width: 12,
              height: 4,
              decoration: BoxDecoration(
                  color: const Color(0xFFFFD500),
                  border:
                      Border.all(color: const Color(0xFF333333), width: 0.5))),
          const SizedBox(width: 4),
          Text('Sticker lato',
              style: th.textTheme.bodyMedium?.copyWith(fontSize: 10)),
        ]),
      ])),
    ]);
  }
}

class _OllPainter extends CustomPainter {
  final String ollStr; // 9 chars '0'/'1': top-left → bottom-right
  _OllPainter(this.ollStr);

  // ignore: constant_identifier_names
  static const _Y = Color(0xFFFFD500); // yellow = oriented
  // ignore: constant_identifier_names
  static const _Gy = Color(0xFF555555); // grey = needs flipping
  // ignore: constant_identifier_names
  static const _Or = Color(0xFFFF5800); // orange = unoriented edge sticker

  // Edge sticker orientation: which of the 4 edge pieces show yellow on top?
  // Derived from the OLL string bits 1(top),3(left),5(right),7(bottom)
  // bit=1 → that edge is oriented (yellow on top, white on side)

  @override
  void paint(Canvas cv, Size sz) {
    final w = sz.width;
    final margin = w * 0.18; // space for side stickers
    final cell = (w - 2 * margin) / 3;
    final ox = margin, oy = margin;
    final ep = Paint()
      ..color = Colors.black.withValues(alpha: 0.25)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.6;

    // ── Top face 3×3 grid ──────────────────────────────────
    for (int i = 0; i < 9; i++) {
      final r = i ~/ 3, c = i % 3;
      final isY = (i < ollStr.length && ollStr[i] == '1') || i == 4;
      final rect = RRect.fromRectAndRadius(
          Rect.fromLTWH(
              ox + c * cell + 0.5, oy + r * cell + 0.5, cell - 1, cell - 1),
          Radius.circular(cell * 0.15));
      cv.drawRRect(rect, Paint()..color = isY ? _Y : _Gy);
      cv.drawRRect(rect, ep);
    }

    // ── Side edge stickers (yellow line = oriented, orange = flipped) ──
    // These show the edge piece sticker on the side face
    final stickerH = margin * 0.55;
    final stickerGap = 1.0;
    final edgeP = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5
      ..color = Colors.black.withValues(alpha: 0.3);

    // Top edge (bit index 1 in ollStr)
    for (int c = 0; c < 3; c++) {
      final isOriented = ollStr.length > 1 && ollStr[1] == '1';
      final col = (c == 1) ? (isOriented ? _Y : _Or) : _Gy;
      if (c == 1) {
        // only center edge sticker
        final r = RRect.fromRectAndRadius(
            Rect.fromLTWH(ox + cell + stickerGap, oy - stickerH - stickerGap,
                cell - 2 * stickerGap, stickerH),
            const Radius.circular(2));
        cv.drawRRect(r, Paint()..color = col);
        cv.drawRRect(r, edgeP);
      }
    }
    // Bottom edge (bit 7)
    {
      final isOriented = ollStr.length > 7 && ollStr[7] == '1';
      final col = isOriented ? _Y : _Or;
      final r = RRect.fromRectAndRadius(
          Rect.fromLTWH(ox + cell + stickerGap, oy + 3 * cell + stickerGap,
              cell - 2 * stickerGap, stickerH),
          const Radius.circular(2));
      cv.drawRRect(r, Paint()..color = col);
      cv.drawRRect(r, edgeP);
    }
    // Left edge (bit 3)
    {
      final isOriented = ollStr.length > 3 && ollStr[3] == '1';
      final col = isOriented ? _Y : _Or;
      final r = RRect.fromRectAndRadius(
          Rect.fromLTWH(ox - stickerH - stickerGap, oy + cell + stickerGap,
              stickerH, cell - 2 * stickerGap),
          const Radius.circular(2));
      cv.drawRRect(r, Paint()..color = col);
      cv.drawRRect(r, edgeP);
    }
    // Right edge (bit 5)
    {
      final isOriented = ollStr.length > 5 && ollStr[5] == '1';
      final col = isOriented ? _Y : _Or;
      final r = RRect.fromRectAndRadius(
          Rect.fromLTWH(ox + 3 * cell + stickerGap, oy + cell + stickerGap,
              stickerH, cell - 2 * stickerGap),
          const Radius.circular(2));
      cv.drawRRect(r, Paint()..color = col);
      cv.drawRRect(r, edgeP);
    }
  }

  @override
  bool shouldRepaint(_OllPainter o) => o.ollStr != ollStr;
}

// ── PLL Diagram: top view with colored stickers + arrows ──────
// Each side has 3 stickers. Arrows show where pieces move.
// This gives an accurate visual of each PLL case.
class _PllDiagram extends StatelessWidget {
  final String name;
  final Color accent;
  const _PllDiagram({required this.name, required this.accent});
  @override
  Widget build(BuildContext context) {
    final th = Theme.of(context);
    return Row(children: [
      SizedBox(
          width: 90,
          height: 90,
          child: CustomPaint(painter: _PllPainter(name))),
      const SizedBox(width: 10),
      Expanded(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(name,
            style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 13,
                color: th.colorScheme.onSurface)),
        const SizedBox(height: 4),
        Text('Vista top: frecce = dove si sposta il pezzo',
            style: th.textTheme.bodyMedium?.copyWith(fontSize: 10)),
      ])),
    ]);
  }
}

class _PllPainter extends CustomPainter {
  final String name;
  _PllPainter(this.name);

  // Colors for each side face: F=red, R=blue, B=orange, L=green
  static const _F = Color(0xFFBA0C2F);
  static const _R = Color(0xFF003DA5);
  static const _B = Color(0xFFFF5800);
  static const _L = Color(0xFF009B48);
  static const _Y = Color(0xFFFFD500);
  static const _K = Color(0xFF111111);

  // PLL sticker patterns: [front3, right3, back3, left3]
  // Each group = 3 stickers (left→right from that side's perspective)
  // Solved state: F=[F,F,F] R=[R,R,R] B=[B,B,B] L=[L,L,L]
  static const _solved = [
    [_F, _F, _F],
    [_R, _R, _R],
    [_B, _B, _B],
    [_L, _L, _L]
  ];

  // PLL states: each list has [front, right, back, left] groups
  // where group = [left, center, right] stickers of that side
  static const Map<String, List<List<Color>>> _pllStates = {
    // U perms: 3 edge cycle on front/right/back
    'Ua': [
      [_L, _F, _F],
      [_F, _R, _R],
      [_R, _B, _B],
      [_L, _L, _B]
    ],
    'Ub': [
      [_R, _F, _F],
      [_B, _R, _R],
      [_L, _B, _B],
      [_L, _L, _F]
    ],
    // H: opposite edge swap ×2
    'H': [
      [_B, _F, _B],
      [_R, _R, _R],
      [_F, _B, _F],
      [_L, _L, _L]
    ],
    // Z: adjacent edge swap ×2
    'Z': [
      [_F, _R, _F],
      [_F, _R, _F],
      [_B, _L, _B],
      [_B, _L, _B]
    ],
    // T: swap FR corners + FB edges
    'T': [
      [_F, _F, _R],
      [_F, _R, _R],
      [_B, _B, _B],
      [_L, _L, _L]
    ],
    // Y: diagonal corner swap
    'Y': [
      [_B, _F, _F],
      [_R, _R, _F],
      [_F, _B, _B],
      [_L, _L, _R]
    ],
    // A perms: 3 corner cycle
    'Aa': [
      [_L, _F, _F],
      [_R, _R, _B],
      [_F, _B, _B],
      [_L, _L, _R]
    ],
    'Ab': [
      [_R, _F, _F],
      [_R, _R, _F],
      [_B, _B, _B],
      [_L, _L, _R]
    ],
    // J perms
    'Ja': [
      [_F, _F, _R],
      [_R, _R, _F],
      [_B, _B, _B],
      [_L, _L, _L]
    ],
    'Jb': [
      [_R, _F, _F],
      [_F, _R, _R],
      [_B, _B, _B],
      [_L, _L, _L]
    ],
    // R perms
    'Ra': [
      [_F, _F, _R],
      [_R, _R, _B],
      [_B, _B, _F],
      [_L, _L, _L]
    ],
    'Rb': [
      [_F, _F, _B],
      [_R, _R, _F],
      [_B, _B, _R],
      [_L, _L, _L]
    ],
    // V perm
    'V': [
      [_B, _F, _F],
      [_R, _R, _F],
      [_F, _B, _B],
      [_R, _L, _L]
    ],
    // F perm
    'F': [
      [_F, _F, _R],
      [_L, _R, _R],
      [_B, _B, _B],
      [_L, _L, _F]
    ],
    // G perms (4 cycle)
    'Ga': [
      [_L, _F, _B],
      [_F, _R, _R],
      [_R, _B, _F],
      [_L, _L, _B]
    ],
    'Gb': [
      [_R, _F, _L],
      [_B, _R, _R],
      [_L, _B, _R],
      [_F, _L, _L]
    ],
    'Gc': [
      [_R, _F, _F],
      [_B, _R, _L],
      [_L, _B, _B],
      [_F, _L, _R]
    ],
    'Gd': [
      [_L, _F, _F],
      [_F, _R, _B],
      [_B, _B, _R],
      [_L, _L, _L]
    ],
    // E perm: diagonal corners swap both
    'E': [
      [_B, _F, _B],
      [_L, _R, _L],
      [_F, _B, _F],
      [_R, _L, _R]
    ],
    // N perms
    'Na': [
      [_F, _F, _F],
      [_R, _R, _R],
      [_B, _B, _B],
      [_L, _L, _L]
    ],
    'Nb': [
      [_F, _F, _F],
      [_R, _R, _R],
      [_B, _B, _B],
      [_L, _L, _L]
    ],
    'PLL - Skip': [
      [_F, _F, _F],
      [_R, _R, _R],
      [_B, _B, _B],
      [_L, _L, _L]
    ],
  };

  @override
  void paint(Canvas cv, Size sz) {
    final w = sz.width;
    final margin = w * 0.20;
    final faceSize = (w - 2 * margin);
    final cell = faceSize / 3;
    final ox = margin, oy = margin;
    final ep = Paint()
      ..color = _K.withValues(alpha: 0.25)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;
    final stickerH = margin * 0.6;

    // Top face: all yellow
    for (int r = 0; r < 3; r++) {
      for (int c = 0; c < 3; c++) {
        final rect = RRect.fromRectAndRadius(
            Rect.fromLTWH(
                ox + c * cell + 0.5, oy + r * cell + 0.5, cell - 1, cell - 1),
            const Radius.circular(2));
        cv.drawRRect(rect, Paint()..color = _Y);
        cv.drawRRect(rect, ep);
      }
    }

    // Side stickers — use PLL state or solved
    final pllKey = _pllStates.keys
        .firstWhere((k) => name.contains(k) || name == k, orElse: () => '');
    final state = pllKey.isNotEmpty ? _pllStates[pllKey]! : _solved;

    // Front side (bottom of diagram)
    for (int c = 0; c < 3; c++) {
      final rect = RRect.fromRectAndRadius(
          Rect.fromLTWH(
              ox + c * cell + 0.5, oy + faceSize + 1, cell - 1, stickerH),
          const Radius.circular(2));
      cv.drawRRect(rect, Paint()..color = state[0][c]);
      cv.drawRRect(rect, ep);
    }
    // Right side
    for (int r = 0; r < 3; r++) {
      final rect = RRect.fromRectAndRadius(
          Rect.fromLTWH(
              ox + faceSize + 1, oy + r * cell + 0.5, stickerH, cell - 1),
          const Radius.circular(2));
      cv.drawRRect(rect, Paint()..color = state[1][r]);
      cv.drawRRect(rect, ep);
    }
    // Back side (top of diagram, reversed)
    for (int c = 0; c < 3; c++) {
      final rect = RRect.fromRectAndRadius(
          Rect.fromLTWH(
              ox + c * cell + 0.5, oy - stickerH - 1, cell - 1, stickerH),
          const Radius.circular(2));
      cv.drawRRect(rect, Paint()..color = state[2][2 - c]);
      cv.drawRRect(rect, ep);
    }
    // Left side
    for (int r = 0; r < 3; r++) {
      final rect = RRect.fromRectAndRadius(
          Rect.fromLTWH(
              ox - stickerH - 1, oy + r * cell + 0.5, stickerH, cell - 1),
          const Radius.circular(2));
      cv.drawRRect(rect, Paint()..color = state[3][r]);
      cv.drawRRect(rect, ep);
    }

    // ── Arrows showing piece movement ───────────────────────
    if (pllKey.isNotEmpty && pllKey != 'PLL - Skip') {
      _drawArrows(cv, ox, oy, faceSize, cell);
    }
  }

  void _drawArrows(
      Canvas cv, double ox, double oy, double faceSize, double cell) {
    final ap = Paint()
      ..color = Colors.white.withValues(alpha: 0.9)
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    void arrow(Offset from, Offset to) {
      cv.drawLine(from, to, ap);
      final dir = to - from;
      final len = dir.distance;
      if (len < 1) return;
      final norm = Offset(dir.dx / len, dir.dy / len);
      final perp = Offset(-norm.dy, norm.dx);
      cv.drawLine(to, to - norm * 6 + perp * 3, ap);
      cv.drawLine(to, to - norm * 6 - perp * 3, ap);
    }

    final cx = ox + faceSize / 2, cy = oy + faceSize / 2;

    // Determine arrow pattern from PLL key
    if (name.contains('Ua')) {
      // CCW 3-cycle: F→L→B edges
      arrow(Offset(cx, oy + cell * 0.5), Offset(ox + cell * 0.5, cy));
      arrow(
          Offset(ox + cell * 0.5, cy), Offset(cx, oy + faceSize - cell * 0.5));
      arrow(
          Offset(cx, oy + faceSize - cell * 0.5), Offset(cx, oy + cell * 0.5));
    } else if (name.contains('Ub')) {
      // CW 3-cycle
      arrow(
          Offset(cx, oy + cell * 0.5), Offset(cx, oy + faceSize - cell * 0.5));
      arrow(Offset(cx, oy + faceSize - cell * 0.5),
          Offset(ox + faceSize - cell * 0.5, cy));
      arrow(
          Offset(ox + faceSize - cell * 0.5, cy), Offset(cx, oy + cell * 0.5));
    } else if (name == 'H') {
      // 2 opposite swaps
      arrow(
          Offset(ox + cell * 0.5, cy), Offset(ox + faceSize - cell * 0.5, cy));
      arrow(
          Offset(ox + faceSize - cell * 0.5, cy), Offset(ox + cell * 0.5, cy));
    } else if (name == 'Z') {
      // Adjacent edge swaps
      arrow(
          Offset(cx, oy + cell * 0.5), Offset(ox + faceSize - cell * 0.5, cy));
      arrow(
          Offset(ox + faceSize - cell * 0.5, cy), Offset(cx, oy + cell * 0.5));
      arrow(
          Offset(cx, oy + faceSize - cell * 0.5), Offset(ox + cell * 0.5, cy));
      arrow(
          Offset(ox + cell * 0.5, cy), Offset(cx, oy + faceSize - cell * 0.5));
    } else if (name.contains('Aa')) {
      // CCW corner 3-cycle
      arrow(Offset(ox, oy), Offset(ox + faceSize, oy));
      arrow(Offset(ox + faceSize, oy), Offset(cx, oy + faceSize));
      arrow(Offset(cx, oy + faceSize), Offset(ox, oy));
    } else if (name.contains('Ab')) {
      // CW corner 3-cycle
      arrow(Offset(ox, oy), Offset(cx, oy + faceSize));
      arrow(Offset(cx, oy + faceSize), Offset(ox + faceSize, oy));
      arrow(Offset(ox + faceSize, oy), Offset(ox, oy));
    } else if (name == 'T' || name.contains('Ja') || name.contains('Jb')) {
      // 2-swap corners + edges
      arrow(Offset(ox, oy), Offset(ox + faceSize, oy));
      arrow(Offset(ox + faceSize, oy), Offset(ox, oy));
      arrow(
          Offset(cx, oy + cell * 0.5), Offset(ox + faceSize - cell * 0.5, cy));
      arrow(
          Offset(ox + faceSize - cell * 0.5, cy), Offset(cx, oy + cell * 0.5));
    } else if (name == 'Y') {
      // Diagonal corner swap
      arrow(Offset(ox, oy), Offset(ox + faceSize, oy + faceSize));
      arrow(Offset(ox + faceSize, oy + faceSize), Offset(ox, oy));
    } else if (name == 'E') {
      // Both diagonal corner swaps
      arrow(Offset(ox, oy), Offset(ox + faceSize, oy + faceSize));
      arrow(Offset(ox + faceSize, oy + faceSize), Offset(ox, oy));
      arrow(Offset(ox + faceSize, oy), Offset(ox, oy + faceSize));
      arrow(Offset(ox, oy + faceSize), Offset(ox + faceSize, oy));
    } else if (name.startsWith('G')) {
      // 4-cycle
      arrow(
          Offset(cx, oy + cell * 0.3), Offset(ox + faceSize - cell * 0.3, cy));
      arrow(Offset(ox + faceSize - cell * 0.3, cy),
          Offset(cx, oy + faceSize - cell * 0.3));
      arrow(
          Offset(cx, oy + faceSize - cell * 0.3), Offset(ox + cell * 0.3, cy));
      arrow(Offset(ox + cell * 0.3, cy), Offset(cx, oy + cell * 0.3));
    } else {
      // Generic: circular arrow for remaining (Ra, Rb, V, F, Na, Nb)
      arrow(
          Offset(cx, oy + cell * 0.4), Offset(ox + faceSize - cell * 0.4, cy));
      arrow(Offset(ox + faceSize - cell * 0.4, cy),
          Offset(cx, oy + faceSize - cell * 0.4));
      arrow(
          Offset(cx, oy + faceSize - cell * 0.4), Offset(cx, oy + cell * 0.4));
    }
  }

  @override
  bool shouldRepaint(_PllPainter o) => o.name != name;
}

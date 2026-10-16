"""Independent exact Posit(8,1) multiplication reference and exhaustive vectors.
Output text format: operand_A operand_B expected_result (two-digit hexadecimal).
"""
from bisect import bisect_left
from fractions import Fraction
from pathlib import Path

N = 8
ES = 1
NAR = 0x80


def decode(bits: int):
    if bits == NAR:
        return None
    if bits == 0:
        return Fraction(0)
    negative = bool(bits & 0x80)
    magnitude = ((-bits) & 0xFF) if negative else bits
    regime_bit = (magnitude >> 6) & 1
    pos = 6
    length = 0
    while pos >= 0 and ((magnitude >> pos) & 1) == regime_bit:
        length += 1
        pos -= 1
    k = length - 1 if regime_bit else -length
    if pos >= 0:
        pos -= 1  # terminator
    exponent = (magnitude >> pos) & 1 if pos >= 0 else 0
    pos -= 1
    frac = Fraction(1)
    power = Fraction(1, 2)
    while pos >= 0:
        if (magnitude >> pos) & 1:
            frac += power
        power /= 2
        pos -= 1
    # useed = 4: value = 4^k * 2^exponent * (1 + fraction)
    scale = Fraction(4**k) if k >= 0 else Fraction(1, 4**(-k))
    val = scale * (2**exponent) * frac
    return -val if negative else val
VALID = sorted((decode(code), code) for code in range(256) if code != NAR)
VALUES = [v for v, _ in VALID]


def encode_nearest(value: Fraction) -> int:
    # No nonzero input product rounds to zero in posit arithmetic: saturate at minpos.
    if value == 0:
        return 0
    # The posit range saturates at +/- maxpos and nonzero magnitudes >= minpos.
    minpos = decode(0x01)
    maxpos = decode(0x7F)
    if 0 < value < minpos:
        return 0x01
    if -minpos < value < 0:
        return 0xFF
    if value >= maxpos:
        return 0x7F
    if value <= -maxpos:
        return 0x81
    ix = bisect_left(VALUES, value)
    if ix < len(VALID) and VALID[ix][0] == value:
        return VALID[ix][1]
    below_v, below_code = VALID[ix - 1]
    above_v, above_code = VALID[ix]
    dist_below = value - below_v
    dist_above = above_v - value
    if dist_below < dist_above:
        return below_code
    if dist_above < dist_below:
        return above_code
    # ties-to-even: Posit LSB=0 is the even representable encoding.
    return below_code if below_code % 2 == 0 else above_code


def main():
    output = Path(__file__).with_name('posit8_es1_all_pairs.txt')
    with output.open('w', encoding='ascii') as f:
        for a in range(256):
            va = decode(a)
            for b in range(256):
                vb = decode(b)
                expected = NAR if va is None or vb is None else encode_nearest(va * vb)
                f.write(f'{a:02X} {b:02X} {expected:02X}\n')
    print(f'Generated 65536 reference vectors: {output}')


if __name__ == '__main__':
    main()

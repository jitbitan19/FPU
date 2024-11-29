import struct


def to_bin(n):
    x = struct.pack(">d", n)
    # bin = "".join(f"{byte:08b}" for byte in x)
    return "".join(f"{byte:08b}" for byte in x)
    # return x.hex()


def to_hex(n):
    x = struct.pack(">d", n)
    return x.hex()


def to_dec(s):
    p = bytes.fromhex(s)
    return struct.unpack(">d", p)[0] * 2


a = 50.69
b = 10.256

print("Verilog command: ")
print(f"\tassign a = 64'b{to_bin(a)};")
print(f"\tassign b = 64'b{to_bin(b)};")

print(f"a: {to_hex(a)}")
print(f"b: {to_hex(b)}")

res = input("Enter result: ")

print(f"Result: {to_dec(res)} , actual ({a*b})")

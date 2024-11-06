import struct


def to_b(n):
    x = struct.pack(">d", n)
    # bin = "".join(f"{byte:08b}" for byte in x)
    return "".join(f"{byte:08b}" for byte in x)
    # return x.hex()


def to_h(n):
    x = struct.pack(">d", n)
    return x.hex()


def to_dec(s):
    p = bytes.fromhex(s)
    return struct.unpack(">d", p)[0] * 2


a = -15.5
b = 6.2

print("Verilog command: ")
print("    initial begin")
print(f"        #10 assign a = 64'b{to_b(a)};")
print(f"            assign b = 64'b{to_b(b)};")
print("    end")

print(f"a: {to_h(a)}")
print(f"b: {to_h(b)}")

res = input("Enter result: ")

print(f"Result: {to_dec(res)} , actual ({a*b})")

import sys

def check_if_list_is_sorted(numbers, instructions):
    l_a = numbers[:]
    l_b = []

    def swap(lst, i, j):
        lst[i], lst[j] = lst[j], lst[i]

    def pa():
        if l_b:
            l_a.insert(0, l_b.pop(0))

    def pb():
        if l_a:
            l_b.insert(0, l_a.pop(0))

    def ra():
        if l_a:
            l_a.append(l_a.pop(0))

    def rb():
        if l_b:
            l_b.append(l_b.pop(0))

    def rra():
        if l_a:
            l_a.insert(0, l_a.pop())

    def rrb():
        if l_b:
            l_b.insert(0, l_b.pop())

    operation_mapping = {
        'sa': lambda: swap(l_a, 0, 1),
        'sb': lambda: swap(l_b, 0, 1),
        'sc': lambda: (swap(l_a, 0, 1), swap(l_b, 0, 1)),
        'pa': pa,
        'pb': pb,
        'ra': ra,
        'rb': rb,
        'rr': lambda: (ra(), rb()),
        'rra': rra,
        'rrb': rrb,
        'rrr': lambda: (rra(), rrb()),
    }

    for instruction in instructions:
        operation = operation_mapping.get(instruction)
        if operation:
            operation()

    return 1 if l_a == sorted(l_a) and not l_b else 0

if __name__ == "__main__":
    with open(sys.argv[1], 'r') as input_file:
        numbers = list(map(int, input_file.readline().strip().split()))
        instructions = input_file.readline().strip().split()

    result = check_if_list_is_sorted(numbers, instructions)
    print(result)

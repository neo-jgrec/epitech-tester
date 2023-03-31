import sys
from typing import Callable, Dict, List, Any
from collections import deque
from functools import partial

class BaseInterpreter:
    instructions: Dict[str, Callable[['BaseInterpreter'], None]] = {}

    def __init__(self, numbers: List[int]):
        self.la: deque = deque(numbers)
        self.lb: deque = deque()

    @staticmethod
    def register(symbol):
        def wrapped(func):
            BaseInterpreter.instructions[symbol] = func
            return func
        return wrapped

class Interpreter(BaseInterpreter):

    @staticmethod
    def register(symbol):
        def wrapped(func):
            Interpreter.instructions[symbol] = func
            return func
        return wrapped

    def execute_instruction(self, symbol: str):
        if symbol in Interpreter.instructions:
            Interpreter.instructions[symbol](self)
        else:
            raise ValueError(f"Unknown instruction: {symbol}")

    @staticmethod
    def _swap(lst: deque, i: int, j: int) -> None:
        lst[i], lst[j] = lst[j], lst[i]

    @BaseInterpreter.register("sa")
    def swap_la(self):
        if len(self.la) > 1:
            self._swap(self.la, 0, 1)

    @BaseInterpreter.register("sb")
    def swap_lb(self):
        if len(self.lb) > 1:
            self._swap(self.lb, 0, 1)

    @BaseInterpreter.register("sc")
    def swap_both(self):
        self.swap_la()
        self.swap_lb()

    @BaseInterpreter.register("pa")
    def push_la(self):
        if self.lb:
            self.la.appendleft(self.lb.popleft())

    @BaseInterpreter.register("pb")
    def push_lb(self):
        if self.la:
            self.lb.appendleft(self.la.popleft())

    @BaseInterpreter.register("ra")
    def rotate_la(self):
        if self.la:
            self.la.rotate(-1)

    @BaseInterpreter.register("rb")
    def rotate_lb(self):
        if self.lb:
            self.lb.rotate(-1)

    @BaseInterpreter.register("rr")
    def rotate_both(self):
        self.rotate_la()
        self.rotate_lb()

    @BaseInterpreter.register("rra")
    def reverse_rotate_la(self):
        if self.la:
            self.la.rotate(1)

    @BaseInterpreter.register("rrb")
    def reverse_rotate_lb(self):
        if self.lb:
            self.lb.rotate(1)

    @BaseInterpreter.register("rrr")
    def reverse_rotate_both(self):
        self.reverse_rotate_la()
        self.reverse_rotate_lb()

    def is_sorted(self):
        return list(self.la) == sorted(self.la) and not self.lb

def main(numbers_file: str, instructions_file: str):
    with open(numbers_file, 'r') as f:
        numbers = list(map(int, f.read().strip().split()))

    with open(instructions_file, 'r') as f:
        instructions = f.read().strip().split()

    interpreter = Interpreter(numbers)

    for instruction in instructions:
        interpreter.execute_instruction(instruction)

    if interpreter.is_sorted():
        print(1)
    else:
        print(0)

if __name__ == "__main__":
    if len(sys.argv) != 3:
        print(f"Usage: {sys.argv[0]} numbers_file instructions_file")
        sys.exit(1)

    main(sys.argv[1], sys.argv[2])

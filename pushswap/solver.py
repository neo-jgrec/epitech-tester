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
            BaseInterpreter.instructions[symbol] = partial(func, interpreter=None)
            return func
        return wrapped

    @staticmethod
    def _swap(lst: deque, i: int, j: int) -> None:
        lst[i], lst[j] = lst[j], lst[i]

class Interpreter(BaseInterpreter):

    def execute_instruction(self, symbol: str):
        if symbol in Interpreter.instructions:
            Interpreter.instructions[symbol](interpreter=self)
        else:
            raise ValueError(f"Unknown instruction: {symbol}")

    @staticmethod
    @BaseInterpreter.register("sa")
    def swap_la(interpreter=None):
        if len(interpreter.la) > 1:
            Interpreter._swap(interpreter.la, 0, 1)

    @staticmethod
    @BaseInterpreter.register("sb")
    def swap_lb(interpreter=None):
        if len(interpreter.lb) > 1:
            Interpreter._swap(interpreter.lb, 0, 1)

    @staticmethod
    @BaseInterpreter.register("sc")
    def swap_both(interpreter=None):
        Interpreter.swap_la(interpreter=interpreter)
        Interpreter.swap_lb(interpreter=interpreter)

    @staticmethod
    @BaseInterpreter.register("pa")
    def push_la(interpreter=None):
        if interpreter.lb:
            interpreter.la.appendleft(interpreter.lb.popleft())

    @staticmethod
    @BaseInterpreter.register("pb")
    def push_lb(interpreter=None):
        if interpreter.la:
            interpreter.lb.appendleft(interpreter.la.popleft())

    @staticmethod
    @BaseInterpreter.register("ra")
    def rotate_la(interpreter=None):
        if interpreter.la:
            interpreter.la.rotate(-1)

    @staticmethod
    @BaseInterpreter.register("rb")
    def rotate_lb(interpreter=None):
        if interpreter.lb:
            interpreter.lb.rotate(-1)

    @staticmethod
    @BaseInterpreter.register("rr")
    def rotate_both(interpreter=None):
        Interpreter.rotate_la(interpreter=interpreter)
        Interpreter.rotate_lb(interpreter=interpreter)

    @staticmethod
    @BaseInterpreter.register("rra")
    def reverse_rotate_la(interpreter=None):
        if interpreter.la:
            interpreter.la.rotate(1)

    @staticmethod
    @BaseInterpreter.register("rrb")
    def reverse_rotate_lb(interpreter=None):
        if interpreter.lb:
            interpreter.lb.rotate(1)

    @staticmethod
    @BaseInterpreter.register("rrr")
    def reverse_rotate_both(interpreter=None):
        Interpreter.reverse_rotate_la(interpreter=interpreter)
        Interpreter.reverse_rotate_lb(interpreter=interpreter)

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

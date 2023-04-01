import sys
from typing import Callable, Dict, List, Any
from collections import deque
from functools import partial, wraps

class BaseInterpreter:
    instructions: Dict[str, Callable[['BaseInterpreter'], None]] = {}

    def __init__(self, numbers: List[int]):
        self.la: deque = deque(numbers)
        self.lb: deque = deque()

    @classmethod
    def register(cls, symbol: str) -> Callable[[Callable[['BaseInterpreter'], None]], Callable[['BaseInterpreter'], None]]:
        def wrapper(func: Callable[['BaseInterpreter'], None]) -> Callable[['BaseInterpreter'], None]:
            @wraps(func)
            def wrapped(interpreter: 'BaseInterpreter') -> None:
                func(interpreter)
            cls.instructions[symbol] = wrapped
            return wrapped
        return wrapper

    @staticmethod
    def _swap(lst: deque, i: int, j: int) -> None:
        lst[i], lst[j] = lst[j], lst[i]

class Interpreter(BaseInterpreter):

    def __init__(self, numbers: List[int]):
        super().__init__(numbers)
        self.partial_instructions = {k: partial(v, self) for k, v in Interpreter.instructions.items()}

    def execute_instruction(self, symbol: str) -> None:
        if symbol in self.partial_instructions:
            self.partial_instructions[symbol]()
        else:
            raise ValueError(f"Unknown instruction: {symbol}")

    @staticmethod
    @BaseInterpreter.register("sa")
    def swap_la(interpreter: 'BaseInterpreter') -> None:
        if len(interpreter.la) > 1:
            Interpreter._swap(interpreter.la, 0, 1)

    @staticmethod
    @BaseInterpreter.register("sb")
    def swap_lb(interpreter: 'BaseInterpreter') -> None:
        if len(interpreter.lb) > 1:
            Interpreter._swap(interpreter.lb, 0, 1)

    @staticmethod
    @BaseInterpreter.register("sc")
    def swap_both(interpreter: 'BaseInterpreter') -> None:
        Interpreter.swap_la(interpreter)
        Interpreter.swap_lb(interpreter)

    @staticmethod
    @BaseInterpreter.register("pa")
    def push_la(interpreter: 'BaseInterpreter') -> None:
        if interpreter.lb:
            interpreter.la.appendleft(interpreter.lb.popleft())

    @staticmethod
    @BaseInterpreter.register("pb")
    def push_lb(interpreter: 'BaseInterpreter') -> None:
        if interpreter.la:
            interpreter.lb.appendleft(interpreter.la.popleft())

    @staticmethod
    @BaseInterpreter.register("ra")
    def rotate_la(interpreter: 'BaseInterpreter') -> None:
        if interpreter.la:
            interpreter.la.rotate(-1)

    @staticmethod
    @BaseInterpreter.register("rb")
    def rotate_lb(interpreter: 'BaseInterpreter') -> None:
        if interpreter.lb:
            interpreter.lb.rotate(-1)

    @staticmethod
    @BaseInterpreter.register("rr")
    def rotate_both(interpreter: 'BaseInterpreter') -> None:
        Interpreter.rotate_la(interpreter)
        Interpreter.rotate_lb(interpreter)

    @staticmethod
    @BaseInterpreter.register("rra")
    def reverse_rotate_la(interpreter: 'BaseInterpreter') -> None:
        if interpreter.la:
            interpreter.la.rotate(1)

    @staticmethod
    @BaseInterpreter.register("rrb")
    def reverse_rotate_lb(interpreter: 'BaseInterpreter') -> None:
        if interpreter.lb:
            interpreter.lb.rotate(1)

    @staticmethod
    @BaseInterpreter.register("rrr")
    def reverse_rotate_both(interpreter: 'BaseInterpreter') -> None:
        Interpreter.reverse_rotate_la(interpreter)
        Interpreter.reverse_rotate_lb(interpreter)

    def is_sorted(self) -> bool:
        return list(self.la) == sorted(self.la) and not self.lb

def main(numbers_file: str, instructions_file: str) -> None:
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

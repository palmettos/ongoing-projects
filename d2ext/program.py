import tkinter as tk
from window import Window

class Manager():

    def __init__(self):

        root = tk.Tk()
        root.resizable(0, 0)
        self.window = Window(root)
        self.window.set_title('d2ext')

        self.
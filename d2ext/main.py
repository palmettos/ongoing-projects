import tkinter as tk
from window import Window

if __name__ == '__main__':
    root = tk.Tk()
    root.resizable(0, 0)
    app = Window(root)
    root.protocol('WM_DELETE_WINDOW', app.kill_thread)
    root.bind('<Destroy>', lambda _: app.kill_thread())
    
    app.set_title('d2ext')
    app.run()
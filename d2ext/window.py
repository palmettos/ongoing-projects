from multiprocessing import Process, Queue
import pygubu
import win32pipe
import pywintypes
from time import sleep
from ui_elements import DynamicElement
from items import ItemState
from pipe import PipeHandler

def comm_loop(queue):

    p = PipeHandler()
    broadcast = False
    username = None
    password = None
    item_state = ItemState()

    while True:

        if not queue.empty():
            event = queue.get()
            name = event['name']

            if name == 'quit':
                print('killing broadcast subprocess')
                return

            if name == 'start':
                username = event['username']
                password = event['key']
                print 'starting broadcast'
                broadcast = True

            if name == 'stop':
                print 'stopping broadcast'
                broadcast = False

        if broadcast:
            try:
                items = p.get_items()
                changed = item_state.update_inventory(items)
                if len(changed) > 0:
                    print(changed)
            except pywintypes.error as e:
                print e
            except AssertionError:
                print 'assertion error'

        sleep(1)


class Window(pygubu.TkApplication):

    def __init__(self, master=None):
        self.dynamic_elements = {}
        pygubu.TkApplication.__init__(self, master)

        self.comm_queue = Queue()
        self.comm_thread = Process(target=comm_loop, args=(self.comm_queue,))
        self.comm_thread.start()

    def _create_ui(self):

        self.builder = builder = pygubu.Builder()
        builder.add_from_file('window.ui')

        self.frame = builder.get_object('frame', self.master)
        self.credentials = builder.get_object('credentials', self.master)
        self.label_username = builder.get_object('label_username', self.master)
        self.text_username = builder.get_object('text_username', self.master)
        self.label_key = builder.get_object('label_key', self.master)
        self.text_key = builder.get_object('text_key', self.master)
        self.button_connect = builder.get_object('button_connect', self.master)

        self.label_message = self.wrap_dynamic(
            builder.get_object('label_message', self.master)
        )
        self.label_message.hide()

        builder.connect_callbacks(self)

    def wrap_dynamic(self, dynamic_element):

        return DynamicElement(dynamic_element)

    def start_broadcast(self):

        self.comm_queue.put(
            {
                'name': 'start',
                'username': self.text_username.get(),
                'key': self.text_key.get()
            }
        )
        self.button_connect.config(text='Disconnect', command=self.stop_broadcast)

    def stop_broadcast(self):

        self.comm_queue.put({'name': 'stop'})
        self.button_connect.config(text='Connect', command=self.start_broadcast)

    def kill_thread(self):

        self.comm_queue.put({'name': 'quit'})
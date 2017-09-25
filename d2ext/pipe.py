import json
import struct
from time import sleep
from ctypes import sizeof, c_int
from win32file import CreateFile, ReadFile, WriteFile, GENERIC_READ, GENERIC_WRITE, OPEN_EXISTING
import pywintypes

DI_PIPE_BUF_SIZE = 1024
SIZEOF_INT = sizeof(c_int)

class PipeHandler():

    def __init__(self):

        self.pipe_name = r'\\.\pipe\DiabloInterfacePipe'

    def _construct_query(self, json_dict):

        s = json.dumps(json_dict, encoding='utf-8')
        return struct.pack('i', len(s)) + s

    def _transact(self, query):

        try:
            h = CreateFile(
                self.pipe_name, GENERIC_READ|GENERIC_WRITE, 0, None, OPEN_EXISTING, 0, None
            )

            packet = self._construct_query(query)
            WriteFile(h, packet)
            read = 0
            err, out = ReadFile(h, DI_PIPE_BUF_SIZE)
            length = struct.unpack('i', out[:SIZEOF_INT])[0]

            while len(out[SIZEOF_INT:]) < length:
                out += ReadFile(h, DI_PIPE_BUF_SIZE)[1]

            data = json.loads(out[SIZEOF_INT:], encoding='utf-8')

        except pywintypes.error as e:
            print e

        else:
            return data

    def get_items(self):

        try:
            response = self._transact({'Resource': 'items', 'Payload': ''})['Payload']
        except TypeError:
            return []
        return response
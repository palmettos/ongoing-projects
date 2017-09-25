

class ItemState():

    def __init__(self):

        self.current_state = {}

    def update_inventory(self, data):

        assert data is not None, 'you must pass in data'

        res = []
        new_equipped_slots = set([item['Location'] for item in data])
        for key in self.current_state.keys():
            if key not in new_equipped_slots:
                try:
                    res.append('removed ' + str(self.current_state[key]['ItemName']))
                    self.current_state.pop(key)
                except KeyError:
                    print 'keyerror', key

        for item in data:
            try:
                if self.current_state[item['Location']] == item:
                    pass
                else:
                    self.current_state[item['Location']] = item
                    res.append('overwrote slot ' + str(item['Location']) + ' with ' + str(item['ItemName']))
            except KeyError:
                self.current_state[item['Location']] = item
                res.append('added ' + str(item['ItemName']))

        return res
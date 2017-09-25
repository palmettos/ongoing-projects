

class DynamicElement():

    def __init__(self, element):

        self.hidden = False
        self.element = element
        self.info = element.grid_info()

    def hide(self):

        assert not self.hidden, 'tried to hide a hidden element'
        self.element.grid_forget()
        self.hidden = True

    def show(self):

        assert self.hidden, 'tried to show a shown element'
        self.element.grid(**self.info)
        self.hidden = False

    def toggle(self):

        if self.hidden:
            self.show()
        else:
            self.hide()
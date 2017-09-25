from pandas import DataFrame as DF
from poloniex import Poloniex
from evaluations import utils
from time import time
import matplotlib.pyplot as plt
import numpy as np
import talib

t = {
    'minute': 60,
    'hour': 60*60,
    'day': 60*60*24,
    'week': 60*60*24*7,
    'month': 60*60*24*30,
    'year': 60*60*24*365
}


class Series:

    def __init__(self, data=None):
        self.data = data

    def plot(self):
        self.recursive_plot(self.data)

    def recursive_plot(self, data):
        if data.ndim > 1:
            for arr in data:
                self.recursive_plot(arr)
        else:
            plt.plot(data)


class Ticker(Series):

    def __init__(self, name, period, pmult, start, smult):
        Series.__init__(self)
        self.api = Poloniex()
        self.name = name
        self.period = t[period] * pmult
        self.start = time() - t[start] * smult
        self.data = self.update()

    def plot(self, columns=['close']):
        for column in columns:
            plt.plot(self.data[column])

    def update(self):
        name = self.name
        period = self.period
        start = self.start
        data = DF(self.api.returnChartData(name, period, start, time()))

        out = {}
        for col in data.keys():
            out[col] = np.array(data[col]).astype('double')

        return out


class Indicator(Series):

    def __init__(self, name, *args):
        self.name = name
        Series.__init__(self)
        data = np.array(getattr(talib, name.upper())(*args))
        if np.ndim(data) > 1:
            self.data = np.array([seq for seq in data])
        else:
            self.data = np.array([data])
        self.begin = 0
        self.clean(self.data)

    def normalize(self, a, b):
        for i in range(len(self.data)):
            self.data[i] = utils.normalize(a, b, self.data[i])

    def clean(self, data):
        for seq in self.data:
            for i in range(len(seq)):
                if np.isnan(seq[i]):
                    seq[i] = 0
                else:
                    if i > self.begin:
                        self.begin = i


class Chart:

    def __init__(self, ticker):
        self.ticker = ticker
        self.indicators = []

    def add_indicator(self, indicator):
        assert len(indicator.data[0]) == len(self.ticker.data['close']), 'sequence length mismatch'
        self.indicators.append(indicator)

    def plot(self):
        self.ticker.plot()
        for indicator in self.indicators:
            indicator.plot()

        plt.show()


class ChartInspector:

    def __init__(self, starting_offset=149):
        self.start = starting_offset
        self.position = self.start

    def step(self):
        self.position += 1

    def rewind(self):
        self.position = self.start

    def lookahead(self, li, dist):
        return li[self.position:self.position+dist]

    def lookback(self, li, dist):
        return li[self.position-dist:self.position]
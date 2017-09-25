'''

'''

import os
from polodata import Ticker, Indicator, Chart, Series, plt, t
from utils import tail
from fitness import price_match
import neat

config_path = 'evaluations/config/macd'

T_UNIT = 'hour'
T_COUNT = 2
R_UNIT = 'month'
R_COUNT = 6
N_LB_UNIT = 'week'
N_LB_COUNT = 3
LA_UNIT = 'day'
LA_COUNT = 1

NORMALIZE_LOOKBACK = (t[N_LB_UNIT]*N_LB_COUNT)/(t[T_UNIT]*T_COUNT)
INPUT_LOOKBACK = NORMALIZE_LOOKBACK - 5
LOOKAHEAD = (t[LA_UNIT]*LA_COUNT)/(t[T_UNIT]*T_COUNT)
FITNESS_INCREMENT = 1.0
THRESHOLD = 0.1

charts = [
    Chart(Ticker('BTC_ETH', T_UNIT, T_COUNT, R_UNIT, R_COUNT)),
    Chart(Ticker('BTC_LTC', T_UNIT, T_COUNT, R_UNIT, R_COUNT)),
    Chart(Ticker('BTC_XRP', T_UNIT, T_COUNT, R_UNIT, R_COUNT)),
    Chart(Ticker('BTC_DASH', T_UNIT, T_COUNT, R_UNIT, R_COUNT)),
    Chart(Ticker('BTC_SC', T_UNIT, T_COUNT, R_UNIT, R_COUNT))
]

total_samples = 0
for chart in charts:

    macd = Indicator('macd', chart.ticker.data['close'])
    # only worth looking at the histogram
    chart.add_indicator(Series([macd.data[2]]))

    # cci = Indicator('cci', chart.ticker.data['high'], chart.ticker.data['low'], chart.ticker.data['close'])
    # chart.add_indicator(cci)

    vol = Series([chart.ticker.data['volume']])
    chart.add_indicator(vol)

    total_samples += len(chart.ticker.data['close'])
print 'Approximate total samples: {}'.format(total_samples)


def get_config():
    local_dir = os.path.dirname(__file__)
    path = os.path.join(local_dir, config_path)
    return neat.Config(
        neat.DefaultGenome,
        neat.DefaultReproduction,
        neat.DefaultSpeciesSet,
        neat.DefaultStagnation,
        config_path
    )


def eval_all(genomes, config):
    for id, genome in genomes:
        genome.fitness = eval_genome(genome, config)


def eval_genome(genome, config):
    return price_match.get_fitness(
        genome, config, charts, NORMALIZE_LOOKBACK, INPUT_LOOKBACK, LOOKAHEAD, THRESHOLD
    )

def plot_checkpoint(checkpoint):
    p = neat.Checkpointer().restore_checkpoint('neat-checkpoint-' + str(checkpoint))
    w = None
    for genome in p.population.values():
        if w is None:
            w = genome
        elif genome.fitness > w.fitness:
            w = genome

    for chart in charts:
        chart.ticker.plot()
        for x, y in price_match.iter_scatter_points(w, get_config(), chart, NORMALIZE_LOOKBACK, INPUT_LOOKBACK):
            plt.scatter(x, y)
        plt.show()
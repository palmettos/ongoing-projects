from polodata import ChartInspector
import neat
from evaluations import utils

def check_peaks(peaks, threshold):
    fitness_delta = 0.0
    highest = None
    for dist, price in enumerate(peaks):
        if highest is None:
            highest = (dist, price)
        elif price > highest[1]:
            highest = (dist, price)
    if highest[1] > peaks[0] * (1 + threshold):
        fitness_delta += 2.0 * highest[0] * (highest[1] / peaks[0])
    else:
        fitness_delta -= 1.0
    return fitness_delta


def iter_output(net, chart, inspector, normalize_lookback, input_lookback):
    out = None
    while inspector.position < len(chart.ticker.data['close']):
        unzipped_input = []
        for indicator in chart.indicators:
            for sequence in indicator.data:
                normalized = utils.normalize(0, 1, inspector.lookback(sequence, normalize_lookback))
                unzipped_input.append(normalized[-input_lookback:])
        net.reset()
        for zipped_input in zip(*unzipped_input):
            out = net.activate(zipped_input)
        yield out
        inspector.step()
    inspector.rewind()


def get_fitness(genome, config, charts, normalize_lookback, input_lookback, lookahead, threshold):
    fitness = 0.0
    net = neat.nn.RecurrentNetwork.create(genome, config)
    inspector = ChartInspector(normalize_lookback + 50)
    for chart in charts:
        for out in iter_output(net, chart, inspector, normalize_lookback, input_lookback):
            if out[0] > 0.5:
                fitness += check_peaks(
                    inspector.lookahead(chart.ticker.data['close'], lookahead), threshold
                )
    return fitness


def iter_scatter_points(genome, config, chart, normalize_lookback, input_lookback):
    net = neat.nn.RecurrentNetwork.create(genome, config)
    inspector = ChartInspector(normalize_lookback + 50)
    for out in iter_output(net, chart, inspector, normalize_lookback, input_lookback):
        if out[0] > 0.5:
            yield inspector.position, chart.ticker.data['close'][inspector.position]
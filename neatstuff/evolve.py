'''
Entry point for performing evolutions.
'''
import os
import neat


def run(generations=50, workers=1, module=None):
    '''Run an evolution.'''
    if module is None:
        print 'You must pass in an evaluation module.'
        return

    pop = neat.Population(module.get_config())
    stats = neat.StatisticsReporter()
    pop.add_reporter(stats)
    pop.add_reporter(neat.StdOutReporter(True))
    pop.add_reporter(neat.Checkpointer(generation_interval=10))

    if workers == 1:
        print 'Running in a single thread...'
        return pop.run(module.eval_all, generations)

    print 'Running in {} threads...'.format(workers)
    evaluator = neat.ParallelEvaluator(workers, module.eval_genome)
    return pop.run(evaluator.evaluate, generations)

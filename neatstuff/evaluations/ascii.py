import os
from fitness import ssim
import neat

config_path = 'evaluations/config/ascii'


def eval_all(genomes, config):
    for id, genome in genomes:
        genome.fitness = eval_genome(genome, config)


def eval_genome(genome, config):
    return ssim.get_fitness(genome, config, grayscale, alphabet)


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
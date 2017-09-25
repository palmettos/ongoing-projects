from selenium import webdriver
from selenium.webdriver.support.wait import WebDriverWait as wdw
import selenium.webdriver.support.expected_conditions as ec

# state traversal functions
def xpath(path):
    return lambda d: d.find_element_by_xpath(path).click()

def css(path):
    return lambda d: d.find_element_by_css_selector(path).click()

graph = {
    'return_to_base': {
        'open_bits_card': css(".bits-toggle")
    },

    'open_bits_card': {
        'get_bits': xpath("//button[@class='button float-right js-buy-bits bits-footer__buy-bits']"),
        'return_to_base': xpath("//button[@class='bits-card__close']")
    },

    'get_bits': {
        'open_bits_card': xpath("//button[@class='bits-purchase__close']"),
        'watch_ad': xpath("//button[@class='button bits-buy--button button--hollow']")
    },

    'watch_ad': {
        'interact_with_ad': '',
        'somethings_wrong': xpath("//div[@class='modal-close-button']")
    },

    'interact_with_ad': {
        'watch_another': xpath("//div[@class='hd-container-header-action']"),
    },

    'watch_another': {
        'return_to_base': xpath("//button[@class='bits-card__close']")
    },

    'somethings_wrong': {
        'return_to_base': xpath("//button[@class='bits-card__close']"),
        'get_bits': xpath("//button[@class='button bits-footer__button']")
    }
}

def get_path(graph, start, goal=None):
    path = {}
    nodes = set(graph.keys())
    visited = set([start])
    weights = {start: 0}

    while nodes:
        try:
            min_node = min({node: weights[node] for node in nodes.intersection(visited)})
        except:
            break

        nodes.remove(min_node)
        current_weight = weights[min_node]

        for edge in graph[min_node]:
            weight = current_weight + 1
            if edge not in visited or weight < weights[edge]:
                visited.add(edge)
                weights[edge] = weight
                path[edge] = min_node
            if edge == goal:
                return path

    return path

def reconstruct_path(src, dest, path):
    steps = [dest]
    current = dest
    while current != src:
        steps.append(path[current])
        current = path[current]

    path = steps[::-1]
    actions = []
    current = src
    for current, next in zip(path[:-1], path[1:]):
        actions.append(graph[current][next])

    return path, actions
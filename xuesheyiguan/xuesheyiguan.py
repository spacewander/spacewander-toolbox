#!/usr/bin/env python3
# coding: utf-8
import random


class City:
    def __init__(self, name, neighbors):
        self.name = name
        self.neighbors = set(neighbors)
        self.owner = ''


cities_data = {
    '沈阳': ('北京', ),
    '北京': ('沈阳', '大同', '冀州'),
    '大同': ('北京', '太原'),
    '冀州': ('北京', '邯郸'),
    '太原': ('大同', '邺'),
    '邯郸': ('冀州', '济南', '邺', '濮阳'),
    '济南': ('邯郸', '济南'),
    '濮阳': ('邯郸', '济南', '小沛', '开封'),
    '邺': ('太原', '濮阳', '邯郸'),
    '徐州': ('济南', '小沛', '南京'),
    '小沛': ('濮阳', '徐州', '淮南', '开封'),
    '开封': ('小沛', '濮阳', '洛阳', '许', '南阳'),
    '许': ('开封', '洛阳', '南阳', '汝南'),
    '洛阳': ('开封', '许', '南阳', '长安'),
    '淮南': ('小沛', '汝南', '合肥'),
    '汝南': ('许', '淮南', '襄阳'),
    '南阳': ('襄阳', '上庸', '长安', '洛阳', '开封', '许'),
    '长安': ('洛阳', '南阳', '汉中', '兰州'),
    '上庸': ('汉中', '南阳'),
    '汉中': ('上庸', '长安', '天水', '梓潼'),
    '天水': ('凉州', '汉中', '兰州'),
    '兰州': ('天水', '长安', '凉州'),
    '凉州': ('天水', '兰州'),
    '梓潼': ('汉中', '成都'),
    '成都': ('梓潼', '重庆', '贵阳'),
    '重庆': ('成都', '宜昌', '贵阳'),
    '宜昌': ('重庆', '岳阳'),
    '贵阳': ('成都', '重庆', '大理'),
    '大理': ('贵阳', ),
    '襄阳': ('南阳', '汝南', '武汉'),
    '荆州': ('襄阳', '岳阳', '武汉'),
    '武汉': ('襄阳', '荆州', '九江'),
    '岳阳': ('荆州', '宜昌', '长沙'),
    '长沙': ('岳阳', '桂林', '南昌'),
    '桂林': ('长沙', '广州'),
    '广州': ('桂林', '南昌'),
    '南昌': ('广州', '九江'),
    '九江': ('武汉', '南昌', '合肥'),
    '合肥': ('九江', '南京', '淮南'),
    '南京': ('合肥', '杭州', '徐州'),
    '杭州': ('南京', '福州'),
    '福州': ('杭州', ),
}
CITIES = {
    name: City(name, neighbors)
    for name, neighbors in cities_data.items()
}


def get_city(name):
    return CITIES[name]


class Player:
    def __init__(self, name, init_power, city_name):
        self._power = init_power
        self.name = name
        self.cities = set()
        self.occupy(city_name)

    def power(self):
        return self._power + len(self.cities)

    def occupy(self, city_name):
        city = get_city(city_name)
        if city.owner != '':
            prev_owner = PLAYERS[city.owner]
            prev_owner.cities.remove(city)
        city.owner = self.name
        self.cities.add(city)

    def occupy_city_from(self, player):
        cities = set([city.name for city in self.cities])
        for city in player.cities:
            neighbors = set([name for name in city.neighbors])
            inter = neighbors.intersection(cities)
            if len(inter) > 0:
                print("%s\t占\t%s\t\t\t%s" % (self.name, city.owner, city.name))
                self.occupy(city.name)
                return True
        return False

    def neighbors(self):
        neighbors = set()
        for city in self.cities:
            for neighbor in city.neighbors:
                neighbor = get_city(neighbor)
                neighbors.add(PLAYERS[neighbor.owner])
        return neighbors

    def win(self, players):
        attack = self.power()
        defence = sum(player.power() for player in players)
        return ((attack) * random.randint(1, 5) >=
                (defence) * random.randint(1, 5))


players_data = {
    "慕容燕": (4,
            '沈阳', ),
    "燕": (1,
          '北京', ),
    "北魏": (4,
           '大同', ),
    "前赵": (2,
           '太原', ),
    "北齐": (3,
           '冀州', ),
    "后赵": (1,
           '邯郸', ),
    "晋": (5,
          '邺', ),
    "齐": (3,
          '济南', ),
    "宋": (6,
          '濮阳', ),
    "后梁": (2,
           '开封', ),
    "唐": (5,
          '洛阳', ),
    "秦": (4,
          '长安', ),
    "后唐": (4,
           '兰州', ),
    "姚秦": (2,
           '天水', ),
    "苻秦": (3,
           '凉州', ),
    "曹魏": (4,
           '许', ),
    "隋": (3,
          '汝南', ),
    "刘宋": (3,
           '九江', ),
    "后周": (2,
           '小沛', ),
    "东汉": (5,
           '南阳', ),
    "萧梁": (3,
           '荆州', ),
    "萧齐": (2,
           '武汉', ),
    "楚": (3,
          '岳阳', ),
    "杨吴": (2,
           '合肥', ),
    "明": (6,
          '南京', ),
    "司马晋": (4,
            '淮南', ),
    "吴": (2,
          '杭州', ),
    "越": (1,
          '福州', ),
    "西楚": (3,
           '徐州', ),
    "北周": (3,
           '汉中', ),
    "成汉": (1,
           '梓潼', ),
    "西汉": (6,
           '成都', ),
    "后蜀": (1,
           '重庆', ),
    "蜀汉": (3,
           '宜昌', ),
    "南平": (1,
           '长沙', ),
    "陈": (2,
          '桂林', ),
    "马楚": (1,
           '广州', ),
    "孙吴": (4,
           '南昌', ),
    "前蜀": (2,
           '贵阳', ),
    "吴三桂": (1,
            '大理', ),
}
PLAYERS = {
    name: Player(name, power, city_name)
    for name, (power, city_name) in players_data.items()
}


def assign_city(city, candidates):
    found = random.choice(candidates)
    for name in PLAYERS:
        if name == found:
            player = PLAYERS[name]
            print('%s 占 %s' % (found, city))
            player.occupy(city)


print('分配空白城市')
assign_city('上庸', ('东汉', '北周'))
assign_city('襄阳', ('隋', '萧齐', '萧梁'))

turn = 0
player_num = len(PLAYERS)
first_time = player_num
delta = 1
while player_num > 1:
    turn += 1
    print("\n第 %d 年" % turn)
    players = [value for value in PLAYERS.values()]
    random.shuffle(players)
    wait_players = set(players)
    while len(wait_players) > 0:
        p1 = wait_players.pop()
        upper = p1.power() * 2 / 3
        p2 = set()
        possible_players = p1.neighbors().intersection(wait_players)
        if len(possible_players) == 0:
            continue
        lower = 0
        while True:
            p = random.choice(tuple(possible_players))
            p2.add(p)
            lower += p.power()
            possible_players.remove(p)
            wait_players.remove(p)
            if turn <= 2 or len(possible_players) == 0 or lower >= upper:
                break
        print("\n%s\t战\t%s" % (p1.name, ' '.join([a.name for a in p2])))
        if p1.win(p2):
            winner = p1
            loser = p2
        else:
            winner = p2
            loser = p1

        if isinstance(winner, set):
            for _ in range(delta):
                for w in winner:
                    if random.choice((True, False)):
                        w.occupy_city_from(loser)
        else:
            for _ in range(delta):
                for l in loser:
                    if random.choice((True, False)):
                        winner.occupy_city_from(l)
        if not isinstance(loser, set):
            loser = {loser}
        for l in loser:
            if len(l.cities) == 0:
                del PLAYERS[l.name]
                print("%s 灭亡了" % l.name)

    player_num = len(PLAYERS)
    print('还剩 %d 家' % player_num)
    if player_num <= 3:
        delta = 8
        if first_time:
            print('进入三国鼎立')
            first_time = 0
    elif player_num <= 7:
        if first_time > 7:
            print('进入战国七雄')
            first_time = 7
        delta = 4
    elif player_num <= 10:
        if first_time > 10:
            print('进入十国并立')
            first_time = 10
        delta = 2
    elif player_num <= 16:
        if first_time > 16:
            print('进入军阀混战')
            first_time = 16
    for player in PLAYERS.values():
        print("%s: %d" % (player.name, len(player.cities)))
        print("%s" % ([city.name for city in player.cities]))

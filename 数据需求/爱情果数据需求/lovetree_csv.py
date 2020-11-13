import json
import pandas as pd
import csv


def express():
    for i in range(1, 4):
        filename = "day0" + str(i) + ".json"
        load_file = None
        with open("./" + filename, "r", encoding='UTF-8') as f:
            load_file = json.load(f)
            header = tuple([i for i in load_file['rankingList'].keys()])
            print(header)
            print(load_file)
            # outputstr = ""
            # for one_dict in load_file['rankingList']:
            #     print(one_dict)
            #     outputstr += one_dict["info"]["uid"] + " " + one_dict["info"]["myName"] + " " + one_dict["info"][
            #         "cpUid"] + " " + one_dict["info"]["cpName"] + " " + str(one_dict["score"]) + " " + str(one_dict["sn"]) + "\n"
            # with open("./dayoutput" + str(i), "w", encoding='UTF-8') as w:
            #     w.writelines(outputstr)
            #

if __name__ == '__main__':
    express()
    print("hello")
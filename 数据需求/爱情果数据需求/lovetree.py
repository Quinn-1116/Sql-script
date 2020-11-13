import json


def express():
    for i in range(1, 4):
        filename = "day0" + str(i) + ".json"
        load_file = None
        print(filename)
        with open("./" + filename, "r", encoding='UTF-8') as f:
            load_file = json.load(f)
            print(load_file)
            outputstr = ""
            for one_dict in load_file['rankingList']:
                print(one_dict)
                outputstr += one_dict["info"]["uid"] + " " + one_dict["info"]["myName"] + " " + one_dict["info"][
                    "cpUid"] + " " + one_dict["info"]["cpName"] + " " + str(one_dict["score"]) + " " + str(one_dict["sn"]) + "\n"
            with open("./dayoutput" + str(i), "w", encoding='UTF-8') as w:
                w.writelines(outputstr)


if __name__ == '__main__':
    express()
    print("hello")
# with open("./day01.json", "r", encoding='UTF-8') as f:
#     load_file = json.load(f)
#     print(load_file['rankingList'])
#     # print(load_file['rankingList'][0]['score'],load_file['rankingList'][0]['sn'])
#     print(load_file['rankingList'][0]['info']['uid'],load_file['rankingList'][0]['info']['myName'],load_file['rankingList'][0]['info']['cpUid'],load_file['rankingList'][0]['info']['cpName'],load_file['rankingList'][0]['score'],load_file['rankingList'][0]['sn'])

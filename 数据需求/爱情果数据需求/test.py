import json


def express():
    for i in range(1, 4):
        filename = "day0" + str(i) + ".json"
        load_file = None
        # # print(filename)
        with open("./"+filename,"r", encoding='UTF-8') as f:
            load_file = json.loads(f)
            print(load_file)
            outputstr = ""
            for one_dict in load_file:
                print(one_dict["score"])
            #     outputstr += one_dict["info"]["uid"] + " " + one_dict["info"]["username"] + " " + str(
            #         one_dict["score"]) + "\n"
            # with open("./dayoutput" + str(i), "w", encoding='UTF-8') as w:
            #     w.writelines(outputstr)


if __name__ == '__main__':
    express()
    print("hello")
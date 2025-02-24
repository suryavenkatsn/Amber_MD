import pandas as pd
from openpyxl import load_workbook
from itertools import islice
import matplotlib as pt
file = 'MD_Tracker.xlsx'
xl = pd.read_excel(file)
type(xl)
# wb = load_workbook('MD_Tracker.xlsx')
# sheet = wb['Sheet1']
# for i in sheet['E2':'E100']:
#     for j in i:
#         print(j.value)
    # print(sheet[i].value, sheet['H"i"'].value, sheet['Q"i"'])
# data = sheet.values
# cols = next(data)[1:]
# data = list(data)
# idx = [r[0] for r in data]
# data = (islice(r, 1, None) for r in data)
# df = pd.DataFrame(data, index = idx, columns=cols)
# print(df)



# data = pd.read_excel('MD_Tracker.xlsx',sheet_name=0)
# print(data['PDB'].loc[0])

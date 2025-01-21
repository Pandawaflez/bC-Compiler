
* 
* ** ** ** ** ** ** ** ** ** ** ** **
* FUNCTION input
  1:     ST  3,-1(1)	Store return address 
  2:     IN  2,2,2	Grab int input 
  3:     LD  3,-1(1)	Load return address 
  4:     LD  1,0(1)	Adjust fp 
  5:    JMP  7,0(3)	Return 
* END FUNCTION input
* 
* ** ** ** ** ** ** ** ** ** ** ** **
* FUNCTION output
  6:     ST  3,-1(1)	Store return address 
  7:     LD  3,-2(1)	Load parameter 
  8:    OUT  3,3,3	Output integer 
  9:     LD  3,-1(1)	Load return address 
 10:     LD  1,0(1)	Adjust fp 
 11:    JMP  7,0(3)	Return 
* END FUNCTION output
* 
* ** ** ** ** ** ** ** ** ** ** ** **
* FUNCTION inputb
 12:     ST  3,-1(1)	Store return address 
 13:    INB  2,2,2	Grab bool input 
 14:     LD  3,-1(1)	Load return address 
 15:     LD  1,0(1)	Adjust fp 
 16:    JMP  7,0(3)	Return 
* END FUNCTION inputb
* 
* ** ** ** ** ** ** ** ** ** ** ** **
* FUNCTION outputb
 17:     ST  3,-1(1)	Store return address 
 18:     LD  3,-2(1)	Load parameter 
 19:   OUTB  3,3,3	Output bool 
 20:     LD  3,-1(1)	Load return address 
 21:     LD  1,0(1)	Adjust fp 
 22:    JMP  7,0(3)	Return 
* END FUNCTION outputb
* 
* ** ** ** ** ** ** ** ** ** ** ** **
* FUNCTION inputc
 23:     ST  3,-1(1)	Store return address 
 24:    INC  2,2,2	Grab char input 
 25:     LD  3,-1(1)	Load return address 
 26:     LD  1,0(1)	Adjust fp 
 27:    JMP  7,0(3)	Return 
* END FUNCTION inputc
* 
* ** ** ** ** ** ** ** ** ** ** ** **
* FUNCTION outputc
 28:     ST  3,-1(1)	Store return address 
 29:     LD  3,-2(1)	Load parameter 
 30:   OUTC  3,3,3	Output char 
 31:     LD  3,-1(1)	Load return address 
 32:     LD  1,0(1)	Adjust fp 
 33:    JMP  7,0(3)	Return 
* END FUNCTION outputc
* 
* ** ** ** ** ** ** ** ** ** ** ** **
* FUNCTION outnl
 34:     ST  3,-1(1)	Store return address 
 35:  OUTNL  3,3,3	Output a newline 
 36:     LD  3,-1(1)	Load return address 
 37:     LD  1,0(1)	Adjust fp 
 38:    JMP  7,0(3)	Return 
* END FUNCTION outnl
* 
* ** ** ** ** ** ** ** ** ** ** ** **
* FUNCTION printText
* TOFF set: -4
 39:     ST  3,-1(1)	Store return address 
* COMPOUND
* TOFF set: -4
* Compound Body
* TOFF set: -7
* FOR
 40:    LDC  3,0(6)	Load integer constant 
 41:     ST  3,-4(1)	save starting value in index variable 
 42:     LD  3,-3(1)	Load variable length
 43:     ST  3,-5(1)	save stop value 
 44:    LDC  3,1(6)	default increment by 1 
 45:     ST  3,-6(1)	save step value 
 46:     LD  4,-4(1)	loop index 
 47:     LD  5,-5(1)	stop value 
 48:     LD  3,-6(1)	step value 
 49:    SLT  3,4,5	Op < 
 50:    JNZ  3,1(7)	Jump to loop body 
* COMPOUND
* TOFF set: -7
* Compound Body
* EXPRESSION
* CALL outputc
 52:     ST  1,-7(1)	Store fp in ghost frame for outputc
* TOFF dec: -8
* TOFF dec: -9
* Param 1
 53:     LD  3,-2(1)	Load address of base of array str
 54:     ST  3,-9(1)	Push left side 
* TOFF dec: -10
 55:     LD  3,-4(1)	Load variable i
* TOFF inc: -9
 56:     LD  4,-9(1)	Pop left into ac1 
 57:    SUB  3,4,3	compute location from index 
 58:     LD  3,0(3)	Load array element 
 59:     ST  3,-9(1)	Push parameter 
* TOFF dec: -10
* Param end outputc
 60:    LDA  1,-7(1)	Ghost frame becomes new active frame 
 61:    LDA  3,1(7)	Return address in ac 
 62:    JMP  7,-35(7)	CALL outputc
 63:    LDA  3,0(2)	Save the result in ac 
* Call end outputc
* TOFF set: -7
* TOFF set: -7
* END COMPOUND
* Bottom of loop increment and jump
 64:     LD  3,-4(1)	Load index 
 65:     LD  5,-6(1)	Load step 
 66:    ADD  3,3,5	increment 
 67:     ST  3,-4(1)	store back to index 
 68:    JMP  7,-23(7)	go to beginning of loop 
 51:    JMP  7,17(7)	Jump past loop [backpatch] 
* END LOOP
* TOFF set: -4
* END COMPOUND
* Add standard closing in case there is no return statement
 69:    LDC  2,0(6)	Set return value to 0 
 70:     LD  3,-1(1)	Load return address 
 71:     LD  1,0(1)	Adjust fp 
 72:    JMP  7,0(3)	Return 
* END FUNCTION printText
* 
* ** ** ** ** ** ** ** ** ** ** ** **
* FUNCTION gameFunctionA
* TOFF set: -5
 73:     ST  3,-1(1)	Store return address 
* COMPOUND
* TOFF set: -5
* Compound Body
* IF
 74:     LD  3,-2(1)	Load variable g
 75:     ST  3,-5(1)	Push left side 
* TOFF dec: -6
 76:    LDC  3,1(6)	Load integer constant 
* TOFF inc: -5
 77:     LD  4,-5(1)	Pop left into ac1 
 78:    TNE  3,4,3	Op != 
* THEN
* COMPOUND
* TOFF set: -5
* Compound Body
* IF
 80:     LD  3,-4(1)	Load address of base of array t
 81:     ST  3,-5(1)	Push left side 
* TOFF dec: -6
 82:    LDC  3,0(6)	Load integer constant 
* TOFF inc: -5
 83:     LD  4,-5(1)	Pop left into ac1 
 84:    SUB  3,4,3	compute location from index 
 85:     LD  3,0(3)	Load array element 
 86:     ST  3,-5(1)	Push left side 
* TOFF dec: -6
 87:    LDC  3,0(6)	Load integer constant 
* TOFF inc: -5
 88:     LD  4,-5(1)	Pop left into ac1 
 89:    TNE  3,4,3	Op != 
* THEN
* COMPOUND
* TOFF set: -5
* Compound Body
* EXPRESSION
* CALL outputc
 91:     ST  1,-5(1)	Store fp in ghost frame for outputc
* TOFF dec: -6
* TOFF dec: -7
* Param 1
 92:    LDC  3,103(6)	Load char constant 
 93:     ST  3,-7(1)	Push parameter 
* TOFF dec: -8
* Param end outputc
 94:    LDA  1,-5(1)	Ghost frame becomes new active frame 
 95:    LDA  3,1(7)	Return address in ac 
 96:    JMP  7,-69(7)	CALL outputc
 97:    LDA  3,0(2)	Save the result in ac 
* Call end outputc
* TOFF set: -5
* TOFF set: -5
* END COMPOUND
 90:    JZR  3,8(7)	Jump around the THEN if false [backpatch] 
* ELSE
* COMPOUND
* TOFF set: -5
* Compound Body
* EXPRESSION
* CALL outputc
 99:     ST  1,-5(1)	Store fp in ghost frame for outputc
* TOFF dec: -6
* TOFF dec: -7
* Param 1
100:    LDC  3,111(6)	Load char constant 
101:     ST  3,-7(1)	Push parameter 
* TOFF dec: -8
* Param end outputc
102:    LDA  1,-5(1)	Ghost frame becomes new active frame 
103:    LDA  3,1(7)	Return address in ac 
104:    JMP  7,-77(7)	CALL outputc
105:    LDA  3,0(2)	Save the result in ac 
* Call end outputc
* TOFF set: -5
* EXPRESSION
106:     LD  3,-2(1)	load lhs variable g
107:    LDA  3,1(3)	increment value of g
108:     ST  3,-2(1)	Store variable g
* EXPRESSION
109:     LD  3,-3(1)	load lhs variable h
110:    LDA  3,1(3)	increment value of h
111:     ST  3,-3(1)	Store variable h
* TOFF set: -5
* END COMPOUND
 98:    JMP  7,13(7)	Jump around the ELSE [backpatch] 
* END IF
* TOFF set: -5
* END COMPOUND
 79:    JZR  3,33(7)	Jump around the THEN if false [backpatch] 
* ELSE
* EXPRESSION
* CALL outputc
113:     ST  1,-5(1)	Store fp in ghost frame for outputc
* TOFF dec: -6
* TOFF dec: -7
* Param 1
114:    LDC  3,111(6)	Load char constant 
115:     ST  3,-7(1)	Push parameter 
* TOFF dec: -8
* Param end outputc
116:    LDA  1,-5(1)	Ghost frame becomes new active frame 
117:    LDA  3,1(7)	Return address in ac 
118:    JMP  7,-91(7)	CALL outputc
119:    LDA  3,0(2)	Save the result in ac 
* Call end outputc
* TOFF set: -5
112:    JMP  7,7(7)	Jump around the ELSE [backpatch] 
* END IF
* IF
120:    LDC  3,9(6)	Load integer constant 
121:     ST  3,-5(1)	Push left side 
* TOFF dec: -6
122:    LDC  3,9(6)	Load integer constant 
* TOFF inc: -5
123:     LD  4,-5(1)	Pop left into ac1 
124:    TEQ  3,4,3	Op == 
125:     ST  3,-5(1)	Push left side 
* TOFF dec: -6
126:    LDC  3,1(6)	Load integer constant 
127:     ST  3,-6(1)	Push left side 
* TOFF dec: -7
128:    LDC  3,1(6)	Load integer constant 
* TOFF inc: -6
129:     LD  4,-6(1)	Pop left into ac1 
130:    TEQ  3,4,3	Op == 
* TOFF inc: -5
131:     LD  4,-5(1)	Pop left into ac1 
132:    AND  3,4,3	Op AND 
* THEN
* COMPOUND
* TOFF set: -5
* Compound Body
* RETURN
134:    LDC  3,1(6)	Load integer constant 
135:    LDA  2,0(3)	Copy result to return register 
136:     LD  3,-1(1)	Load return address 
137:     LD  1,0(1)	Adjust fp 
138:    JMP  7,0(3)	Return 
* TOFF set: -5
* END COMPOUND
133:    JZR  3,6(7)	Jump around the THEN if false [backpatch] 
* ELSE
* COMPOUND
* TOFF set: -5
* Compound Body
* IF
140:    LDC  3,9(6)	Load integer constant 
141:     ST  3,-5(1)	Push left side 
* TOFF dec: -6
142:    LDC  3,9(6)	Load integer constant 
* TOFF inc: -5
143:     LD  4,-5(1)	Pop left into ac1 
144:    TEQ  3,4,3	Op == 
145:     ST  3,-5(1)	Push left side 
* TOFF dec: -6
146:    LDC  3,10(6)	Load integer constant 
147:     ST  3,-6(1)	Push left side 
* TOFF dec: -7
148:    LDC  3,10(6)	Load integer constant 
* TOFF inc: -6
149:     LD  4,-6(1)	Pop left into ac1 
150:    TEQ  3,4,3	Op == 
* TOFF inc: -5
151:     LD  4,-5(1)	Pop left into ac1 
152:    AND  3,4,3	Op AND 
* THEN
* COMPOUND
* TOFF set: -5
* Compound Body
* RETURN
154:    LDC  3,1(6)	Load integer constant 
155:    LDA  2,0(3)	Copy result to return register 
156:     LD  3,-1(1)	Load return address 
157:     LD  1,0(1)	Adjust fp 
158:    JMP  7,0(3)	Return 
* TOFF set: -5
* END COMPOUND
153:    JZR  3,5(7)	Jump around the THEN if false [backpatch] 
* END IF
* TOFF set: -5
* END COMPOUND
139:    JMP  7,19(7)	Jump around the ELSE [backpatch] 
* END IF
* WHILE
159:     LD  3,-2(1)	Load variable g
160:     ST  3,-5(1)	Push left side 
* TOFF dec: -6
161:    LDC  3,10(6)	Load integer constant 
* TOFF inc: -5
162:     LD  4,-5(1)	Pop left into ac1 
163:    TLT  3,4,3	Op < 
164:    JNZ  3,1(7)	Jump to while part 
* DO
* IF
166:    LDC  3,0(6)	Load Boolean constant 
* THEN
* EXPRESSION
168:     LD  3,-2(1)	load lhs variable g
169:    LDA  3,1(3)	increment value of g
170:     ST  3,-2(1)	Store variable g
167:    JZR  3,4(7)	Jump around the THEN if false [backpatch] 
* ELSE
* IF
172:    LDC  3,0(6)	Load Boolean constant 
* THEN
* EXPRESSION
174:     LD  3,-2(1)	load lhs variable g
175:    LDA  3,1(3)	increment value of g
176:     ST  3,-2(1)	Store variable g
173:    JZR  3,3(7)	Jump around the THEN if false [backpatch] 
* END IF
171:    JMP  7,5(7)	Jump around the ELSE [backpatch] 
* END IF
177:    JMP  7,-19(7)	go to beginning of loop 
165:    JMP  7,12(7)	Jump past loop [backpatch] 
* END WHILE
* EXPRESSION
178:     LD  3,-2(1)	load lhs variable g
179:    LDA  3,-1(3)	decrement value of g
180:     ST  3,-2(1)	Store variable g
* TOFF set: -8
* FOR
181:    LDC  3,0(6)	Load integer constant 
182:     ST  3,-5(1)	save starting value in index variable 
183:    LDC  3,10(6)	Load integer constant 
184:     ST  3,-6(1)	save stop value 
185:    LDC  3,2(6)	Load integer constant 
186:     ST  3,-7(1)	save step value 
187:     LD  4,-5(1)	loop index 
188:     LD  5,-6(1)	stop value 
189:     LD  3,-7(1)	step value 
190:    SLT  3,4,5	Op < 
191:    JNZ  3,1(7)	Jump to loop body 
* IF
193:    LDC  3,1(6)	Load integer constant 
194:     ST  3,-8(1)	Push left side 
* TOFF dec: -9
195:     LD  3,-5(1)	Load variable y
* TOFF inc: -8
196:     LD  4,-8(1)	Pop left into ac1 
197:    TEQ  3,4,3	Op == 
* THEN
* BREAK
199:    JMP  7,-8(7)	break 
198:    JZR  3,1(7)	Jump around the THEN if false [backpatch] 
* END IF
* Bottom of loop increment and jump
200:     LD  3,-5(1)	Load index 
201:     LD  5,-7(1)	Load step 
202:    ADD  3,3,5	increment 
203:     ST  3,-5(1)	store back to index 
204:    JMP  7,-18(7)	go to beginning of loop 
192:    JMP  7,12(7)	Jump past loop [backpatch] 
* END LOOP
* RETURN
205:     LD  3,-2(1)	Load variable g
206:     ST  3,-8(1)	Push left side 
* TOFF dec: -9
207:     LD  3,-4(1)	Load address of base of array t
208:     ST  3,-9(1)	Push left side 
* TOFF dec: -10
209:    LDC  3,0(6)	Load integer constant 
* TOFF inc: -9
210:     LD  4,-9(1)	Pop left into ac1 
211:    SUB  3,4,3	compute location from index 
212:     LD  3,0(3)	Load array element 
* TOFF inc: -8
213:     LD  4,-8(1)	Pop left into ac1 
214:    ADD  3,4,3	Op + 
215:    LDA  2,0(3)	Copy result to return register 
216:     LD  3,-1(1)	Load return address 
217:     LD  1,0(1)	Adjust fp 
218:    JMP  7,0(3)	Return 
* TOFF set: -5
* END COMPOUND
* Add standard closing in case there is no return statement
219:    LDC  2,0(6)	Set return value to 0 
220:     LD  3,-1(1)	Load return address 
221:     LD  1,0(1)	Adjust fp 
222:    JMP  7,0(3)	Return 
* END FUNCTION gameFunctionA
* 
* ** ** ** ** ** ** ** ** ** ** ** **
* FUNCTION printStatus
* TOFF set: -2
223:     ST  3,-1(1)	Store return address 
* COMPOUND
* TOFF set: -2
* Compound Body
* EXPRESSION
* CALL printText
224:     ST  1,-2(1)	Store fp in ghost frame for printText
* TOFF dec: -3
* TOFF dec: -4
* Param 1
  9:    LIT  "--------------------"
225:    LDA  3,-9(0)	Load address of char array 
226:     ST  3,-4(1)	Push parameter 
* TOFF dec: -5
* Param 2
227:    LDC  3,20(6)	Load integer constant 
228:     ST  3,-5(1)	Push parameter 
* TOFF dec: -6
* Param end printText
229:    LDA  1,-2(1)	Ghost frame becomes new active frame 
230:    LDA  3,1(7)	Return address in ac 
231:    JMP  7,-193(7)	CALL printText
232:    LDA  3,0(2)	Save the result in ac 
* Call end printText
* TOFF set: -2
* EXPRESSION
* CALL outnl
233:     ST  1,-2(1)	Store fp in ghost frame for outnl
* TOFF dec: -3
* TOFF dec: -4
* Param end outnl
234:    LDA  1,-2(1)	Ghost frame becomes new active frame 
235:    LDA  3,1(7)	Return address in ac 
236:    JMP  7,-203(7)	CALL outnl
237:    LDA  3,0(2)	Save the result in ac 
* Call end outnl
* TOFF set: -2
* EXPRESSION
* CALL outputc
238:     ST  1,-2(1)	Store fp in ghost frame for outputc
* TOFF dec: -3
* TOFF dec: -4
* Param 1
239:     LD  3,-6(0)	Load variable playerChar
240:     ST  3,-4(1)	Push parameter 
* TOFF dec: -5
* Param end outputc
241:    LDA  1,-2(1)	Ghost frame becomes new active frame 
242:    LDA  3,1(7)	Return address in ac 
243:    JMP  7,-216(7)	CALL outputc
244:    LDA  3,0(2)	Save the result in ac 
* Call end outputc
* TOFF set: -2
* EXPRESSION
* CALL outputc
245:     ST  1,-2(1)	Store fp in ghost frame for outputc
* TOFF dec: -3
* TOFF dec: -4
* Param 1
246:    LDC  3,32(6)	Load char constant 
247:     ST  3,-4(1)	Push parameter 
* TOFF dec: -5
* Param end outputc
248:    LDA  1,-2(1)	Ghost frame becomes new active frame 
249:    LDA  3,1(7)	Return address in ac 
250:    JMP  7,-223(7)	CALL outputc
251:    LDA  3,0(2)	Save the result in ac 
* Call end outputc
* TOFF set: -2
* EXPRESSION
* CALL outputc
252:     ST  1,-2(1)	Store fp in ghost frame for outputc
* TOFF dec: -3
* TOFF dec: -4
* Param 1
253:    LDC  3,118(6)	Load char constant 
254:     ST  3,-4(1)	Push parameter 
* TOFF dec: -5
* Param end outputc
255:    LDA  1,-2(1)	Ghost frame becomes new active frame 
256:    LDA  3,1(7)	Return address in ac 
257:    JMP  7,-230(7)	CALL outputc
258:    LDA  3,0(2)	Save the result in ac 
* Call end outputc
* TOFF set: -2
* EXPRESSION
* CALL outputc
259:     ST  1,-2(1)	Store fp in ghost frame for outputc
* TOFF dec: -3
* TOFF dec: -4
* Param 1
260:    LDC  3,115(6)	Load char constant 
261:     ST  3,-4(1)	Push parameter 
* TOFF dec: -5
* Param end outputc
262:    LDA  1,-2(1)	Ghost frame becomes new active frame 
263:    LDA  3,1(7)	Return address in ac 
264:    JMP  7,-237(7)	CALL outputc
265:    LDA  3,0(2)	Save the result in ac 
* Call end outputc
* TOFF set: -2
* EXPRESSION
* CALL outputc
266:     ST  1,-2(1)	Store fp in ghost frame for outputc
* TOFF dec: -3
* TOFF dec: -4
* Param 1
267:    LDC  3,32(6)	Load char constant 
268:     ST  3,-4(1)	Push parameter 
* TOFF dec: -5
* Param end outputc
269:    LDA  1,-2(1)	Ghost frame becomes new active frame 
270:    LDA  3,1(7)	Return address in ac 
271:    JMP  7,-244(7)	CALL outputc
272:    LDA  3,0(2)	Save the result in ac 
* Call end outputc
* TOFF set: -2
* EXPRESSION
* CALL outnl
273:     ST  1,-2(1)	Store fp in ghost frame for outnl
* TOFF dec: -3
* TOFF dec: -4
* Param end outnl
274:    LDA  1,-2(1)	Ghost frame becomes new active frame 
275:    LDA  3,1(7)	Return address in ac 
276:    JMP  7,-243(7)	CALL outnl
277:    LDA  3,0(2)	Save the result in ac 
* Call end outnl
* TOFF set: -2
* EXPRESSION
* CALL outputc
278:     ST  1,-2(1)	Store fp in ghost frame for outputc
* TOFF dec: -3
* TOFF dec: -4
* Param 1
279:     LD  3,-5(0)	Load variable monsterChar
280:     ST  3,-4(1)	Push parameter 
* TOFF dec: -5
* Param end outputc
281:    LDA  1,-2(1)	Ghost frame becomes new active frame 
282:    LDA  3,1(7)	Return address in ac 
283:    JMP  7,-256(7)	CALL outputc
284:    LDA  3,0(2)	Save the result in ac 
* Call end outputc
* TOFF set: -2
* EXPRESSION
* CALL printText
285:     ST  1,-2(1)	Store fp in ghost frame for printText
* TOFF dec: -3
* TOFF dec: -4
* Param 1
 30:    LIT  "Player Health: "
286:    LDA  3,-30(0)	Load address of char array 
287:     ST  3,-4(1)	Push parameter 
* TOFF dec: -5
* Param 2
288:    LDC  3,15(6)	Load integer constant 
289:     ST  3,-5(1)	Push parameter 
* TOFF dec: -6
* Param end printText
290:    LDA  1,-2(1)	Ghost frame becomes new active frame 
291:    LDA  3,1(7)	Return address in ac 
292:    JMP  7,-254(7)	CALL printText
293:    LDA  3,0(2)	Save the result in ac 
* Call end printText
* TOFF set: -2
* EXPRESSION
* CALL output
294:     ST  1,-2(1)	Store fp in ghost frame for output
* TOFF dec: -3
* TOFF dec: -4
* Param 1
295:     LD  3,-1(0)	Load variable playerHealth
296:     ST  3,-4(1)	Push parameter 
* TOFF dec: -5
* Param end output
297:    LDA  1,-2(1)	Ghost frame becomes new active frame 
298:    LDA  3,1(7)	Return address in ac 
299:    JMP  7,-294(7)	CALL output
300:    LDA  3,0(2)	Save the result in ac 
* Call end output
* TOFF set: -2
* EXPRESSION
* CALL outnl
301:     ST  1,-2(1)	Store fp in ghost frame for outnl
* TOFF dec: -3
* TOFF dec: -4
* Param end outnl
302:    LDA  1,-2(1)	Ghost frame becomes new active frame 
303:    LDA  3,1(7)	Return address in ac 
304:    JMP  7,-271(7)	CALL outnl
305:    LDA  3,0(2)	Save the result in ac 
* Call end outnl
* TOFF set: -2
* EXPRESSION
* CALL printText
306:     ST  1,-2(1)	Store fp in ghost frame for printText
* TOFF dec: -3
* TOFF dec: -4
* Param 1
 46:    LIT  "Monster Health: "
307:    LDA  3,-46(0)	Load address of char array 
308:     ST  3,-4(1)	Push parameter 
* TOFF dec: -5
* Param 2
309:    LDC  3,16(6)	Load integer constant 
310:     ST  3,-5(1)	Push parameter 
* TOFF dec: -6
* Param end printText
311:    LDA  1,-2(1)	Ghost frame becomes new active frame 
312:    LDA  3,1(7)	Return address in ac 
313:    JMP  7,-275(7)	CALL printText
314:    LDA  3,0(2)	Save the result in ac 
* Call end printText
* TOFF set: -2
* EXPRESSION
* CALL output
315:     ST  1,-2(1)	Store fp in ghost frame for output
* TOFF dec: -3
* TOFF dec: -4
* Param 1
316:     LD  3,0(0)	Load variable monsterHealth
317:     ST  3,-4(1)	Push parameter 
* TOFF dec: -5
* Param end output
318:    LDA  1,-2(1)	Ghost frame becomes new active frame 
319:    LDA  3,1(7)	Return address in ac 
320:    JMP  7,-315(7)	CALL output
321:    LDA  3,0(2)	Save the result in ac 
* Call end output
* TOFF set: -2
* EXPRESSION
* CALL outnl
322:     ST  1,-2(1)	Store fp in ghost frame for outnl
* TOFF dec: -3
* TOFF dec: -4
* Param end outnl
323:    LDA  1,-2(1)	Ghost frame becomes new active frame 
324:    LDA  3,1(7)	Return address in ac 
325:    JMP  7,-292(7)	CALL outnl
326:    LDA  3,0(2)	Save the result in ac 
* Call end outnl
* TOFF set: -2
* EXPRESSION
* CALL printText
327:     ST  1,-2(1)	Store fp in ghost frame for printText
* TOFF dec: -3
* TOFF dec: -4
* Param 1
 63:    LIT  "--------------------"
328:    LDA  3,-63(0)	Load address of char array 
329:     ST  3,-4(1)	Push parameter 
* TOFF dec: -5
* Param 2
330:    LDC  3,20(6)	Load integer constant 
331:     ST  3,-5(1)	Push parameter 
* TOFF dec: -6
* Param end printText
332:    LDA  1,-2(1)	Ghost frame becomes new active frame 
333:    LDA  3,1(7)	Return address in ac 
334:    JMP  7,-296(7)	CALL printText
335:    LDA  3,0(2)	Save the result in ac 
* Call end printText
* TOFF set: -2
* EXPRESSION
* CALL outnl
336:     ST  1,-2(1)	Store fp in ghost frame for outnl
* TOFF dec: -3
* TOFF dec: -4
* Param end outnl
337:    LDA  1,-2(1)	Ghost frame becomes new active frame 
338:    LDA  3,1(7)	Return address in ac 
339:    JMP  7,-306(7)	CALL outnl
340:    LDA  3,0(2)	Save the result in ac 
* Call end outnl
* TOFF set: -2
* TOFF set: -2
* END COMPOUND
* Add standard closing in case there is no return statement
341:    LDC  2,0(6)	Set return value to 0 
342:     LD  3,-1(1)	Load return address 
343:     LD  1,0(1)	Adjust fp 
344:    JMP  7,0(3)	Return 
* END FUNCTION printStatus
* 
* ** ** ** ** ** ** ** ** ** ** ** **
* FUNCTION takeTurn
* TOFF set: -3
345:     ST  3,-1(1)	Store return address 
* COMPOUND
* TOFF set: -6
* Compound Body
* EXPRESSION
346:     LD  3,-83(0)	load lhs variable baseDamage
347:    LDA  3,1(3)	increment value of baseDamage
348:     ST  3,-83(0)	Store variable baseDamage
* EXPRESSION
349:     LD  3,-83(0)	Load variable baseDamage
350:     ST  3,-6(1)	Push left side 
* TOFF dec: -7
351:    LDC  3,10(6)	Load integer constant 
352:    RND  3,3,6	Op ? 
* TOFF inc: -6
353:     LD  4,-6(1)	Pop left into ac1 
354:    ADD  3,4,3	Op + 
355:     ST  3,-4(1)	Store variable monsterDamage
* IF
356:     LD  3,-7(0)	Load variable isTrue
* THEN
* COMPOUND
* TOFF set: -6
* Compound Body
* EXPRESSION
358:    LDC  3,1(6)	Load Boolean constant 
359:     ST  3,-5(1)	Store variable sanityCheck
* TOFF set: -6
* END COMPOUND
357:    JZR  3,3(7)	Jump around the THEN if false [backpatch] 
* ELSE
* COMPOUND
* TOFF set: -6
* Compound Body
* EXPRESSION
361:    LDC  3,0(6)	Load Boolean constant 
362:     ST  3,-5(1)	Store variable sanityCheck
* TOFF set: -6
* END COMPOUND
360:    JMP  7,2(7)	Jump around the ELSE [backpatch] 
* END IF
* IF
363:     LD  3,-2(1)	Load variable x
364:     ST  3,-6(1)	Push left side 
* TOFF dec: -7
365:    LDC  3,1(6)	Load integer constant 
* TOFF inc: -6
366:     LD  4,-6(1)	Pop left into ac1 
367:    TEQ  3,4,3	Op == 
* THEN
* COMPOUND
* TOFF set: -7
* Compound Body
* EXPRESSION
369:    LDC  3,3(6)	Load integer constant 
370:     ST  3,-7(1)	Push left side 
* TOFF dec: -8
371:    LDC  3,5(6)	Load integer constant 
* TOFF inc: -7
372:     LD  4,-7(1)	Pop left into ac1 
373:    SWP  4,3,3	Op :>: 
374:     ST  3,-6(1)	Store variable t
* EXPRESSION
375:     LD  3,-6(1)	Load variable t
376:     ST  3,-7(1)	Push left side 
* TOFF dec: -8
377:     LD  3,-6(1)	Load variable t
* TOFF inc: -7
378:     LD  4,-7(1)	Pop left into ac1 
379:    SUB  3,4,3	Op - 
380:     ST  3,-6(1)	Store variable t
* EXPRESSION
* CALL printText
381:     ST  1,-7(1)	Store fp in ghost frame for printText
* TOFF dec: -8
* TOFF dec: -9
* Param 1
 85:    LIT  "You Attack!"
382:    LDA  3,-85(0)	Load address of char array 
383:     ST  3,-9(1)	Push parameter 
* TOFF dec: -10
* Param 2
384:    LDC  3,11(6)	Load integer constant 
385:     ST  3,-10(1)	Push parameter 
* TOFF dec: -11
* Param end printText
386:    LDA  1,-7(1)	Ghost frame becomes new active frame 
387:    LDA  3,1(7)	Return address in ac 
388:    JMP  7,-350(7)	CALL printText
389:    LDA  3,0(2)	Save the result in ac 
* Call end printText
* TOFF set: -7
* EXPRESSION
* CALL outnl
390:     ST  1,-7(1)	Store fp in ghost frame for outnl
* TOFF dec: -8
* TOFF dec: -9
* Param end outnl
391:    LDA  1,-7(1)	Ghost frame becomes new active frame 
392:    LDA  3,1(7)	Return address in ac 
393:    JMP  7,-360(7)	CALL outnl
394:    LDA  3,0(2)	Save the result in ac 
* Call end outnl
* TOFF set: -7
* EXPRESSION
395:     LD  3,-83(0)	Load variable baseDamage
396:     ST  3,-7(1)	Push left side 
* TOFF dec: -8
397:    LDC  3,10(6)	Load integer constant 
398:    RND  3,3,6	Op ? 
* TOFF inc: -7
399:     LD  4,-7(1)	Pop left into ac1 
400:    ADD  3,4,3	Op + 
401:     ST  3,-3(1)	Store variable playerDamage
* EXPRESSION
402:     LD  3,-3(1)	Load variable playerDamage
403:     LD  4,0(0)	load lhs variable monsterHealth
404:    SUB  3,4,3	op -= 
405:     ST  3,0(0)	Store variable monsterHealth
* TOFF set: -6
* END COMPOUND
368:    JZR  3,37(7)	Jump around the THEN if false [backpatch] 
* END IF
* IF
406:     LD  3,-2(1)	Load variable x
407:     ST  3,-6(1)	Push left side 
* TOFF dec: -7
408:    LDC  3,2(6)	Load integer constant 
* TOFF inc: -6
409:     LD  4,-6(1)	Pop left into ac1 
410:    TEQ  3,4,3	Op == 
* THEN
* COMPOUND
* TOFF set: -7
* Compound Body
* EXPRESSION
412:    LDC  3,3(6)	Load integer constant 
413:     ST  3,-7(1)	Push left side 
* TOFF dec: -8
414:    LDC  3,5(6)	Load integer constant 
* TOFF inc: -7
415:     LD  4,-7(1)	Pop left into ac1 
416:    SWP  3,4,3	Op :<: 
417:     ST  3,-6(1)	Store variable t
* EXPRESSION
* CALL printText
418:     ST  1,-7(1)	Store fp in ghost frame for printText
* TOFF dec: -8
* TOFF dec: -9
* Param 1
 97:    LIT  "You Block!"
419:    LDA  3,-97(0)	Load address of char array 
420:     ST  3,-9(1)	Push parameter 
* TOFF dec: -10
* Param 2
421:    LDC  3,10(6)	Load integer constant 
422:     ST  3,-10(1)	Push parameter 
* TOFF dec: -11
* Param end printText
423:    LDA  1,-7(1)	Ghost frame becomes new active frame 
424:    LDA  3,1(7)	Return address in ac 
425:    JMP  7,-387(7)	CALL printText
426:    LDA  3,0(2)	Save the result in ac 
* Call end printText
* TOFF set: -7
* EXPRESSION
* CALL outnl
427:     ST  1,-7(1)	Store fp in ghost frame for outnl
* TOFF dec: -8
* TOFF dec: -9
* Param end outnl
428:    LDA  1,-7(1)	Ghost frame becomes new active frame 
429:    LDA  3,1(7)	Return address in ac 
430:    JMP  7,-397(7)	CALL outnl
431:    LDA  3,0(2)	Save the result in ac 
* Call end outnl
* TOFF set: -7
* EXPRESSION
432:    LDC  3,2(6)	Load integer constant 
433:     LD  4,-4(1)	load lhs variable monsterDamage
434:    DIV  3,4,3	op /= 
435:     ST  3,-4(1)	Store variable monsterDamage
* EXPRESSION
* CALL printText
436:     ST  1,-7(1)	Store fp in ghost frame for printText
* TOFF dec: -8
* TOFF dec: -9
* Param 1
108:    LIT  "Monster's Damage was halved!"
437:    LDA  3,-108(0)	Load address of char array 
438:     ST  3,-9(1)	Push parameter 
* TOFF dec: -10
* Param 2
439:    LDC  3,28(6)	Load integer constant 
440:     ST  3,-10(1)	Push parameter 
* TOFF dec: -11
* Param end printText
441:    LDA  1,-7(1)	Ghost frame becomes new active frame 
442:    LDA  3,1(7)	Return address in ac 
443:    JMP  7,-405(7)	CALL printText
444:    LDA  3,0(2)	Save the result in ac 
* Call end printText
* TOFF set: -7
* EXPRESSION
* CALL outnl
445:     ST  1,-7(1)	Store fp in ghost frame for outnl
* TOFF dec: -8
* TOFF dec: -9
* Param end outnl
446:    LDA  1,-7(1)	Ghost frame becomes new active frame 
447:    LDA  3,1(7)	Return address in ac 
448:    JMP  7,-415(7)	CALL outnl
449:    LDA  3,0(2)	Save the result in ac 
* Call end outnl
* TOFF set: -7
* TOFF set: -6
* END COMPOUND
411:    JZR  3,38(7)	Jump around the THEN if false [backpatch] 
* END IF
* EXPRESSION
* CALL printText
450:     ST  1,-6(1)	Store fp in ghost frame for printText
* TOFF dec: -7
* TOFF dec: -8
* Param 1
137:    LIT  "Enemy Attacks!"
451:    LDA  3,-137(0)	Load address of char array 
452:     ST  3,-8(1)	Push parameter 
* TOFF dec: -9
* Param 2
453:    LDC  3,14(6)	Load integer constant 
454:     ST  3,-9(1)	Push parameter 
* TOFF dec: -10
* Param end printText
455:    LDA  1,-6(1)	Ghost frame becomes new active frame 
456:    LDA  3,1(7)	Return address in ac 
457:    JMP  7,-419(7)	CALL printText
458:    LDA  3,0(2)	Save the result in ac 
* Call end printText
* TOFF set: -6
* EXPRESSION
459:     LD  3,-4(1)	Load variable monsterDamage
460:     LD  4,-1(0)	load lhs variable playerHealth
461:    SUB  3,4,3	op -= 
462:     ST  3,-1(0)	Store variable playerHealth
* TOFF set: -3
* END COMPOUND
* Add standard closing in case there is no return statement
463:    LDC  2,0(6)	Set return value to 0 
464:     LD  3,-1(1)	Load return address 
465:     LD  1,0(1)	Adjust fp 
466:    JMP  7,0(3)	Return 
* END FUNCTION takeTurn
* 
* ** ** ** ** ** ** ** ** ** ** ** **
* FUNCTION checkTime
* TOFF set: -3
467:     ST  3,-1(1)	Store return address 
* COMPOUND
* TOFF set: -3
* Compound Body
* IF
468:     LD  3,-2(1)	Load variable numOfTurns
469:     ST  3,-3(1)	Push left side 
* TOFF dec: -4
470:    LDC  3,5(6)	Load integer constant 
* TOFF inc: -3
471:     LD  4,-3(1)	Pop left into ac1 
472:    TLE  3,4,3	Op <= 
473:     ST  3,-3(1)	Push left side 
* TOFF dec: -4
474:     LD  3,-2(1)	Load variable numOfTurns
475:     ST  3,-4(1)	Push left side 
* TOFF dec: -5
476:    LDC  3,2(6)	Load integer constant 
* TOFF inc: -4
477:     LD  4,-4(1)	Pop left into ac1 
478:    MOD  3,4,3	Op % 
479:     ST  3,-4(1)	Push left side 
* TOFF dec: -5
480:    LDC  3,0(6)	Load integer constant 
* TOFF inc: -4
481:     LD  4,-4(1)	Pop left into ac1 
482:    TEQ  3,4,3	Op == 
* TOFF inc: -3
483:     LD  4,-3(1)	Pop left into ac1 
484:    AND  3,4,3	Op AND 
485:     ST  3,-3(1)	Push left side 
* TOFF dec: -4
486:     LD  3,-2(1)	Load variable numOfTurns
487:     ST  3,-4(1)	Push left side 
* TOFF dec: -5
488:    LDC  3,0(6)	Load integer constant 
* TOFF inc: -4
489:     LD  4,-4(1)	Pop left into ac1 
490:    TGE  3,4,3	Op >= 
* TOFF inc: -3
491:     LD  4,-3(1)	Pop left into ac1 
492:     OR  3,4,3	Op OR 
* THEN
* COMPOUND
* TOFF set: -4
* Compound Body
* EXPRESSION
494:    LDC  3,0(6)	Load integer constant 
495:     ST  3,-3(1)	Store variable ulessVal
* EXPRESSION
496:    LDC  3,1(6)	Load integer constant 
497:     LD  4,-3(1)	load lhs variable ulessVal
498:    ADD  3,4,3	op += 
499:     ST  3,-3(1)	Store variable ulessVal
* EXPRESSION
500:     LD  3,-2(1)	Load variable numOfTurns
501:     LD  4,-3(1)	load lhs variable ulessVal
502:    MUL  3,4,3	op *= 
503:     ST  3,-3(1)	Store variable ulessVal
* IF
504:     LD  3,-3(1)	Load variable ulessVal
505:     ST  3,-4(1)	Push left side 
* TOFF dec: -5
506:    LDC  3,10021325(6)	Load integer constant 
* TOFF inc: -4
507:     LD  4,-4(1)	Pop left into ac1 
508:    TEQ  3,4,3	Op == 
* THEN
* COMPOUND
* TOFF set: -4
* Compound Body
* EXPRESSION
* CALL printText
510:     ST  1,-4(1)	Store fp in ghost frame for printText
* TOFF dec: -5
* TOFF dec: -6
* Param 1
152:    LIT  "Iime is rumming our!"
511:    LDA  3,-152(0)	Load address of char array 
512:     ST  3,-6(1)	Push parameter 
* TOFF dec: -7
* Param 2
513:    LDC  3,20(6)	Load integer constant 
514:     ST  3,-7(1)	Push parameter 
* TOFF dec: -8
* Param end printText
515:    LDA  1,-4(1)	Ghost frame becomes new active frame 
516:    LDA  3,1(7)	Return address in ac 
517:    JMP  7,-479(7)	CALL printText
518:    LDA  3,0(2)	Save the result in ac 
* Call end printText
* TOFF set: -4
* EXPRESSION
* CALL outnl
519:     ST  1,-4(1)	Store fp in ghost frame for outnl
* TOFF dec: -5
* TOFF dec: -6
* Param end outnl
520:    LDA  1,-4(1)	Ghost frame becomes new active frame 
521:    LDA  3,1(7)	Return address in ac 
522:    JMP  7,-489(7)	CALL outnl
523:    LDA  3,0(2)	Save the result in ac 
* Call end outnl
* TOFF set: -4
* TOFF set: -4
* END COMPOUND
509:    JZR  3,14(7)	Jump around the THEN if false [backpatch] 
* END IF
* RETURN
524:    LDC  3,1(6)	Load integer constant 
525:    LDA  2,0(3)	Copy result to return register 
526:     LD  3,-1(1)	Load return address 
527:     LD  1,0(1)	Adjust fp 
528:    JMP  7,0(3)	Return 
* TOFF set: -3
* END COMPOUND
493:    JZR  3,36(7)	Jump around the THEN if false [backpatch] 
* ELSE
* IF
530:     LD  3,-2(1)	Load variable numOfTurns
531:     ST  3,-3(1)	Push left side 
* TOFF dec: -4
532:    LDC  3,10(6)	Load integer constant 
* TOFF inc: -3
533:     LD  4,-3(1)	Pop left into ac1 
534:    TLE  3,4,3	Op <= 
* THEN
* COMPOUND
* TOFF set: -3
* Compound Body
* EXPRESSION
* CALL printText
536:     ST  1,-3(1)	Store fp in ghost frame for printText
* TOFF dec: -4
* TOFF dec: -5
* Param 1
173:    LIT  "Time is running out!"
537:    LDA  3,-173(0)	Load address of char array 
538:     ST  3,-5(1)	Push parameter 
* TOFF dec: -6
* Param 2
539:    LDC  3,20(6)	Load integer constant 
540:     ST  3,-6(1)	Push parameter 
* TOFF dec: -7
* Param end printText
541:    LDA  1,-3(1)	Ghost frame becomes new active frame 
542:    LDA  3,1(7)	Return address in ac 
543:    JMP  7,-505(7)	CALL printText
544:    LDA  3,0(2)	Save the result in ac 
* Call end printText
* TOFF set: -3
* EXPRESSION
* CALL outnl
545:     ST  1,-3(1)	Store fp in ghost frame for outnl
* TOFF dec: -4
* TOFF dec: -5
* Param end outnl
546:    LDA  1,-3(1)	Ghost frame becomes new active frame 
547:    LDA  3,1(7)	Return address in ac 
548:    JMP  7,-515(7)	CALL outnl
549:    LDA  3,0(2)	Save the result in ac 
* Call end outnl
* TOFF set: -3
* RETURN
550:    LDC  3,1(6)	Load integer constant 
551:    LDA  2,0(3)	Copy result to return register 
552:     LD  3,-1(1)	Load return address 
553:     LD  1,0(1)	Adjust fp 
554:    JMP  7,0(3)	Return 
* TOFF set: -3
* END COMPOUND
535:    JZR  3,20(7)	Jump around the THEN if false [backpatch] 
* ELSE
* COMPOUND
* TOFF set: -3
* Compound Body
* EXPRESSION
* CALL printText
556:     ST  1,-3(1)	Store fp in ghost frame for printText
* TOFF dec: -4
* TOFF dec: -5
* Param 1
194:    LIT  "Time ran out!"
557:    LDA  3,-194(0)	Load address of char array 
558:     ST  3,-5(1)	Push parameter 
* TOFF dec: -6
* Param 2
559:    LDC  3,13(6)	Load integer constant 
560:     ST  3,-6(1)	Push parameter 
* TOFF dec: -7
* Param end printText
561:    LDA  1,-3(1)	Ghost frame becomes new active frame 
562:    LDA  3,1(7)	Return address in ac 
563:    JMP  7,-525(7)	CALL printText
564:    LDA  3,0(2)	Save the result in ac 
* Call end printText
* TOFF set: -3
* EXPRESSION
* CALL outnl
565:     ST  1,-3(1)	Store fp in ghost frame for outnl
* TOFF dec: -4
* TOFF dec: -5
* Param end outnl
566:    LDA  1,-3(1)	Ghost frame becomes new active frame 
567:    LDA  3,1(7)	Return address in ac 
568:    JMP  7,-535(7)	CALL outnl
569:    LDA  3,0(2)	Save the result in ac 
* Call end outnl
* TOFF set: -3
* TOFF set: -3
* END COMPOUND
555:    JMP  7,14(7)	Jump around the ELSE [backpatch] 
* END IF
529:    JMP  7,40(7)	Jump around the ELSE [backpatch] 
* END IF
* RETURN
570:    LDC  3,0(6)	Load integer constant 
571:    LDA  2,0(3)	Copy result to return register 
572:     LD  3,-1(1)	Load return address 
573:     LD  1,0(1)	Adjust fp 
574:    JMP  7,0(3)	Return 
* TOFF set: -3
* END COMPOUND
* Add standard closing in case there is no return statement
575:    LDC  2,0(6)	Set return value to 0 
576:     LD  3,-1(1)	Load return address 
577:     LD  1,0(1)	Adjust fp 
578:    JMP  7,0(3)	Return 
* END FUNCTION checkTime
* 
* ** ** ** ** ** ** ** ** ** ** ** **
* FUNCTION main
* TOFF set: -2
579:     ST  3,-1(1)	Store return address 
* COMPOUND
* TOFF set: -4
* Compound Body
* EXPRESSION
580:    LDC  3,1(6)	Load integer constant 
581:     ST  3,-2(1)	Store variable x
* EXPRESSION
582:    LDC  3,0(6)	Load integer constant 
583:     ST  3,-3(1)	Store variable numOfTurns
* WHILE
584:     LD  3,-2(1)	Load variable x
585:     ST  3,-4(1)	Push left side 
* TOFF dec: -5
586:    LDC  3,2(6)	Load integer constant 
* TOFF inc: -4
587:     LD  4,-4(1)	Pop left into ac1 
588:    TNE  3,4,3	Op != 
589:    JNZ  3,1(7)	Jump to while part 
* DO
* COMPOUND
* TOFF set: -6
591:    LDC  3,0(6)	Load integer constant 
592:     ST  3,-5(1)	Store variable ghjrk
* Compound Body
* WHILE
593:     LD  3,-5(1)	Load variable ghjrk
594:     ST  3,-6(1)	Push left side 
* TOFF dec: -7
595:    LDC  3,10(6)	Load integer constant 
* TOFF inc: -6
596:     LD  4,-6(1)	Pop left into ac1 
597:    TLT  3,4,3	Op < 
598:    JNZ  3,1(7)	Jump to while part 
* DO
* EXPRESSION
600:     LD  3,-5(1)	load lhs variable ghjrk
601:    LDA  3,1(3)	increment value of ghjrk
602:     ST  3,-5(1)	Store variable ghjrk
603:    JMP  7,-11(7)	go to beginning of loop 
599:    JMP  7,4(7)	Jump past loop [backpatch] 
* END WHILE
* EXPRESSION
* CALL printStatus
604:     ST  1,-6(1)	Store fp in ghost frame for printStatus
* TOFF dec: -7
* TOFF dec: -8
* Param end printStatus
605:    LDA  1,-6(1)	Ghost frame becomes new active frame 
606:    LDA  3,1(7)	Return address in ac 
607:    JMP  7,-385(7)	CALL printStatus
608:    LDA  3,0(2)	Save the result in ac 
* Call end printStatus
* TOFF set: -6
* EXPRESSION
* CALL printText
609:     ST  1,-6(1)	Store fp in ghost frame for printText
* TOFF dec: -7
* TOFF dec: -8
* Param 1
208:    LIT  "What do you want to do?"
610:    LDA  3,-208(0)	Load address of char array 
611:     ST  3,-8(1)	Push parameter 
* TOFF dec: -9
* Param 2
612:    LDC  3,23(6)	Load integer constant 
613:     ST  3,-9(1)	Push parameter 
* TOFF dec: -10
* Param end printText
614:    LDA  1,-6(1)	Ghost frame becomes new active frame 
615:    LDA  3,1(7)	Return address in ac 
616:    JMP  7,-578(7)	CALL printText
617:    LDA  3,0(2)	Save the result in ac 
* Call end printText
* TOFF set: -6
* EXPRESSION
* CALL outnl
618:     ST  1,-6(1)	Store fp in ghost frame for outnl
* TOFF dec: -7
* TOFF dec: -8
* Param end outnl
619:    LDA  1,-6(1)	Ghost frame becomes new active frame 
620:    LDA  3,1(7)	Return address in ac 
621:    JMP  7,-588(7)	CALL outnl
622:    LDA  3,0(2)	Save the result in ac 
* Call end outnl
* TOFF set: -6
* EXPRESSION
* CALL printText
623:     ST  1,-6(1)	Store fp in ghost frame for printText
* TOFF dec: -7
* TOFF dec: -8
* Param 1
232:    LIT  "1) Attack"
624:    LDA  3,-232(0)	Load address of char array 
625:     ST  3,-8(1)	Push parameter 
* TOFF dec: -9
* Param 2
626:    LDC  3,9(6)	Load integer constant 
627:     ST  3,-9(1)	Push parameter 
* TOFF dec: -10
* Param end printText
628:    LDA  1,-6(1)	Ghost frame becomes new active frame 
629:    LDA  3,1(7)	Return address in ac 
630:    JMP  7,-592(7)	CALL printText
631:    LDA  3,0(2)	Save the result in ac 
* Call end printText
* TOFF set: -6
* EXPRESSION
* CALL outnl
632:     ST  1,-6(1)	Store fp in ghost frame for outnl
* TOFF dec: -7
* TOFF dec: -8
* Param end outnl
633:    LDA  1,-6(1)	Ghost frame becomes new active frame 
634:    LDA  3,1(7)	Return address in ac 
635:    JMP  7,-602(7)	CALL outnl
636:    LDA  3,0(2)	Save the result in ac 
* Call end outnl
* TOFF set: -6
* EXPRESSION
* CALL printText
637:     ST  1,-6(1)	Store fp in ghost frame for printText
* TOFF dec: -7
* TOFF dec: -8
* Param 1
242:    LIT  "2) Block"
638:    LDA  3,-242(0)	Load address of char array 
639:     ST  3,-8(1)	Push parameter 
* TOFF dec: -9
* Param 2
640:    LDC  3,8(6)	Load integer constant 
641:     ST  3,-9(1)	Push parameter 
* TOFF dec: -10
* Param end printText
642:    LDA  1,-6(1)	Ghost frame becomes new active frame 
643:    LDA  3,1(7)	Return address in ac 
644:    JMP  7,-606(7)	CALL printText
645:    LDA  3,0(2)	Save the result in ac 
* Call end printText
* TOFF set: -6
* EXPRESSION
* CALL outnl
646:     ST  1,-6(1)	Store fp in ghost frame for outnl
* TOFF dec: -7
* TOFF dec: -8
* Param end outnl
647:    LDA  1,-6(1)	Ghost frame becomes new active frame 
648:    LDA  3,1(7)	Return address in ac 
649:    JMP  7,-616(7)	CALL outnl
650:    LDA  3,0(2)	Save the result in ac 
* Call end outnl
* TOFF set: -6
* EXPRESSION
* CALL input
651:     ST  1,-6(1)	Store fp in ghost frame for input
* TOFF dec: -7
* TOFF dec: -8
* Param end input
652:    LDA  1,-6(1)	Ghost frame becomes new active frame 
653:    LDA  3,1(7)	Return address in ac 
654:    JMP  7,-654(7)	CALL input
655:    LDA  3,0(2)	Save the result in ac 
* Call end input
* TOFF set: -6
656:     ST  3,-2(1)	Store variable x
* EXPRESSION
* CALL takeTurn
657:     ST  1,-6(1)	Store fp in ghost frame for takeTurn
* TOFF dec: -7
* TOFF dec: -8
* Param 1
658:     LD  3,-2(1)	Load variable x
659:     ST  3,-8(1)	Push parameter 
* TOFF dec: -9
* Param end takeTurn
660:    LDA  1,-6(1)	Ghost frame becomes new active frame 
661:    LDA  3,1(7)	Return address in ac 
662:    JMP  7,-318(7)	CALL takeTurn
663:    LDA  3,0(2)	Save the result in ac 
* Call end takeTurn
* TOFF set: -6
* IF
664:    LDC  3,0(6)	Load integer constant 
665:     ST  3,-6(1)	Push left side 
* TOFF dec: -7
666:     LD  3,-1(0)	Load variable playerHealth
* TOFF inc: -6
667:     LD  4,-6(1)	Pop left into ac1 
668:    TGE  3,4,3	Op >= 
669:     ST  3,-6(1)	Push left side 
* TOFF dec: -7
670:     LD  3,0(0)	Load variable monsterHealth
671:     ST  3,-7(1)	Push left side 
* TOFF dec: -8
672:    LDC  3,1(6)	Load integer constant 
* TOFF inc: -7
673:     LD  4,-7(1)	Pop left into ac1 
674:    TLT  3,4,3	Op < 
* TOFF inc: -6
675:     LD  4,-6(1)	Pop left into ac1 
676:     OR  3,4,3	Op OR 
* THEN
* COMPOUND
* TOFF set: -7
* Compound Body
* EXPRESSION
678:     LD  3,-2(1)	Load variable x
679:     ST  3,-6(1)	Store variable u
* EXPRESSION
680:     LD  3,-6(1)	Load variable u
681:     ST  3,-7(1)	Push left side 
* TOFF dec: -8
682:     LD  3,-6(1)	Load variable u
* TOFF inc: -7
683:     LD  4,-7(1)	Pop left into ac1 
684:    MUL  3,4,3	Op * 
685:     ST  3,-6(1)	Store variable u
* EXPRESSION
686:     LD  3,-6(1)	Load variable u
687:     ST  3,-7(1)	Push left side 
* TOFF dec: -8
688:     LD  3,-6(1)	Load variable u
* TOFF inc: -7
689:     LD  4,-7(1)	Pop left into ac1 
690:    DIV  3,4,3	Op / 
691:     ST  3,-6(1)	Store variable u
* EXPRESSION
692:    LDC  3,2(6)	Load integer constant 
693:     ST  3,-6(1)	Store variable u
* EXPRESSION
694:     LD  3,-6(1)	Load variable u
695:     ST  3,-2(1)	Store variable x
* TOFF set: -6
* END COMPOUND
677:    JZR  3,19(7)	Jump around the THEN if false [backpatch] 
* ELSE
* EXPRESSION
697:    LDC  3,10(6)	Load integer constant 
698:     ST  3,-4(0)	Store variable k
696:    JMP  7,2(7)	Jump around the ELSE [backpatch] 
* END IF
* EXPRESSION
699:     LD  3,-3(1)	load lhs variable numOfTurns
700:    LDA  3,1(3)	increment value of numOfTurns
701:     ST  3,-3(1)	Store variable numOfTurns
* EXPRESSION
* CALL checkTime
702:     ST  1,-6(1)	Store fp in ghost frame for checkTime
* TOFF dec: -7
* TOFF dec: -8
* Param 1
703:     LD  3,-3(1)	Load variable numOfTurns
704:     ST  3,-8(1)	Push parameter 
* TOFF dec: -9
* Param end checkTime
705:    LDA  1,-6(1)	Ghost frame becomes new active frame 
706:    LDA  3,1(7)	Return address in ac 
707:    JMP  7,-241(7)	CALL checkTime
708:    LDA  3,0(2)	Save the result in ac 
* Call end checkTime
* TOFF set: -6
709:     ST  3,-4(1)	Store variable timeCheck
* IF
710:     LD  3,-4(1)	Load variable timeCheck
711:     ST  3,-6(1)	Push left side 
* TOFF dec: -7
712:    LDC  3,0(6)	Load integer constant 
* TOFF inc: -6
713:     LD  4,-6(1)	Pop left into ac1 
714:    TEQ  3,4,3	Op == 
* THEN
* COMPOUND
* TOFF set: -15
716:    LDC  3,8(6)	Load integer constant 
717:     ST  3,-6(1)	Store variable u
718:    LDC  3,7(6)	load size of array arr
719:     ST  3,-7(1)	save size of array arr
* Compound Body
* EXPRESSION
720:    LDC  3,0(6)	Load integer constant 
721:     ST  3,-15(1)	Push index 
* TOFF dec: -16
722:    LDC  3,10(6)	Load integer constant 
* TOFF inc: -15
723:     LD  4,-15(1)	Pop index 
724:    LDA  5,-8(1)	Load address of base of array arr
725:    SUB  5,5,4	Compute offset of value 
726:     ST  3,0(5)	Store variable arr
* EXPRESSION
727:     LD  3,-6(1)	Load variable u
728:    NEG  3,3,3	Op unary - 
729:     ST  3,-6(1)	Store variable u
* EXPRESSION
730:     LD  3,-6(1)	Load variable u
731:     ST  3,-15(1)	Push left side 
* TOFF dec: -16
732:     LD  3,-6(1)	Load variable u
733:    NEG  3,3,3	Op unary - 
* TOFF inc: -15
734:     LD  4,-15(1)	Pop left into ac1 
735:    ADD  3,4,3	Op + 
736:     ST  3,-6(1)	Store variable u
* IF
737:     LD  3,-6(1)	Load variable u
738:     ST  3,-15(1)	Push left side 
* TOFF dec: -16
739:    LDC  3,0(6)	Load integer constant 
* TOFF inc: -15
740:     LD  4,-15(1)	Pop left into ac1 
741:    TGT  3,4,3	Op > 
742:    LDC  4,1(6)	Load 1 
743:    XOR  3,3,4	Op XOR to get logical not 
* THEN
* COMPOUND
* TOFF set: -15
* Compound Body
* EXPRESSION
745:    LDA  3,-8(1)	Load address of base of array arr
746:     LD  3,1(3)	Load array size 
747:     ST  3,-6(1)	Store variable u
* TOFF set: -15
* END COMPOUND
744:    JZR  3,3(7)	Jump around the THEN if false [backpatch] 
* END IF
* EXPRESSION
748:     LD  3,-2(0)	load lhs variable h
749:    LDA  3,1(3)	increment value of h
750:     ST  3,-2(0)	Store variable h
* EXPRESSION
751:     LD  3,-3(0)	load lhs variable j
752:    LDA  3,1(3)	increment value of j
753:     ST  3,-3(0)	Store variable j
* EXPRESSION
754:    LDC  3,0(6)	Load integer constant 
755:     LD  4,-1(0)	load lhs variable playerHealth
756:    MUL  3,4,3	op *= 
757:     ST  3,-1(0)	Store variable playerHealth
* BREAK
758:    JMP  7,-169(7)	break 
* TOFF set: -6
* END COMPOUND
715:    JZR  3,43(7)	Jump around the THEN if false [backpatch] 
* END IF
* TOFF set: -4
* END COMPOUND
759:    JMP  7,-176(7)	go to beginning of loop 
590:    JMP  7,169(7)	Jump past loop [backpatch] 
* END WHILE
* IF
760:     LD  3,-1(0)	Load variable playerHealth
761:     ST  3,-4(1)	Push left side 
* TOFF dec: -5
762:    LDC  3,0(6)	Load integer constant 
* TOFF inc: -4
763:     LD  4,-4(1)	Pop left into ac1 
764:    TLT  3,4,3	Op < 
* THEN
* COMPOUND
* TOFF set: -4
* Compound Body
* EXPRESSION
* CALL printText
766:     ST  1,-4(1)	Store fp in ghost frame for printText
* TOFF dec: -5
* TOFF dec: -6
* Param 1
251:    LIT  "You Win!"
767:    LDA  3,-251(0)	Load address of char array 
768:     ST  3,-6(1)	Push parameter 
* TOFF dec: -7
* Param 2
769:    LDC  3,8(6)	Load integer constant 
770:     ST  3,-7(1)	Push parameter 
* TOFF dec: -8
* Param end printText
771:    LDA  1,-4(1)	Ghost frame becomes new active frame 
772:    LDA  3,1(7)	Return address in ac 
773:    JMP  7,-735(7)	CALL printText
774:    LDA  3,0(2)	Save the result in ac 
* Call end printText
* TOFF set: -4
* EXPRESSION
* CALL outnl
775:     ST  1,-4(1)	Store fp in ghost frame for outnl
* TOFF dec: -5
* TOFF dec: -6
* Param end outnl
776:    LDA  1,-4(1)	Ghost frame becomes new active frame 
777:    LDA  3,1(7)	Return address in ac 
778:    JMP  7,-745(7)	CALL outnl
779:    LDA  3,0(2)	Save the result in ac 
* Call end outnl
* TOFF set: -4
* TOFF set: -4
* END COMPOUND
765:    JZR  3,15(7)	Jump around the THEN if false [backpatch] 
* ELSE
* COMPOUND
* TOFF set: -4
* Compound Body
* EXPRESSION
* CALL printText
781:     ST  1,-4(1)	Store fp in ghost frame for printText
* TOFF dec: -5
* TOFF dec: -6
* Param 1
260:    LIT  "You Died!"
782:    LDA  3,-260(0)	Load address of char array 
783:     ST  3,-6(1)	Push parameter 
* TOFF dec: -7
* Param 2
784:    LDC  3,9(6)	Load integer constant 
785:     ST  3,-7(1)	Push parameter 
* TOFF dec: -8
* Param end printText
786:    LDA  1,-4(1)	Ghost frame becomes new active frame 
787:    LDA  3,1(7)	Return address in ac 
788:    JMP  7,-750(7)	CALL printText
789:    LDA  3,0(2)	Save the result in ac 
* Call end printText
* TOFF set: -4
* EXPRESSION
* CALL outnl
790:     ST  1,-4(1)	Store fp in ghost frame for outnl
* TOFF dec: -5
* TOFF dec: -6
* Param end outnl
791:    LDA  1,-4(1)	Ghost frame becomes new active frame 
792:    LDA  3,1(7)	Return address in ac 
793:    JMP  7,-760(7)	CALL outnl
794:    LDA  3,0(2)	Save the result in ac 
* Call end outnl
* TOFF set: -4
* TOFF set: -4
* END COMPOUND
780:    JMP  7,14(7)	Jump around the ELSE [backpatch] 
* END IF
* RETURN
795:     LD  3,-1(1)	Load return address 
796:     LD  1,0(1)	Adjust fp 
797:    JMP  7,0(3)	Return 
* TOFF set: -2
* END COMPOUND
* Add standard closing in case there is no return statement
798:    LDC  2,0(6)	Set return value to 0 
799:     LD  3,-1(1)	Load return address 
800:     LD  1,0(1)	Adjust fp 
801:    JMP  7,0(3)	Return 
* END FUNCTION main
  0:    JMP  7,801(7)	Jump to init [backpatch] 
* INIT
802:    LDA  1,-269(0)	set first frame at end of globals 
803:     ST  1,0(1)	store old fp (point to self) 
* INIT GLOBALS AND STATICS
804:    LDC  3,2(6)	Load integer constant 
805:     ST  3,-83(0)	Store variable baseDamage
806:    LDC  3,1(6)	Load Boolean constant 
807:     ST  3,-7(0)	Store variable isTrue
808:    LDC  3,71(6)	Load char constant 
809:     ST  3,-5(0)	Store variable monsterChar
810:    LDC  3,100(6)	Load integer constant 
811:     ST  3,0(0)	Store variable monsterHealth
812:    LDC  3,72(6)	Load char constant 
813:     ST  3,-6(0)	Store variable playerChar
814:    LDC  3,100(6)	Load integer constant 
815:     ST  3,-1(0)	Store variable playerHealth
* END INIT GLOBALS AND STATICS
816:    LDA  3,1(7)	Return address in ac 
817:    JMP  7,-239(7)	Jump to main 
818:   HALT  0,0,0	DONE! 
* END INIT